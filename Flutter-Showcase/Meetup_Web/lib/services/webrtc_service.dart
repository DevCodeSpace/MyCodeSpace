import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/poll_message.dart';
import 'app_lifecycle_helper.dart';
import 'firebase_signaling_service.dart';

class ChatMessage {
  final String sender; // 'Me' or 'Peer'
  final String text;
  final DateTime timestamp;
  ChatMessage({required this.sender, required this.text, required this.timestamp});
}

class WebRTCService extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseSignalingService signalingService;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _cameraStream;
  MediaStream? _screenShareStream;
  RTCDataChannel? _dataChannel;
  RTCRtpSender? _videoSender;

  List<ChatMessage> chatMessages = [];
  List<PollMessage> polls = [];
  bool hasUnreadMessages = false;
  void Function(ChatMessage)? onNewMessage;
  void Function(String emoji, String senderName)? onNewReaction;
  void Function(PollMessage)? onNewPoll;
  void Function()? onPeerLeft;

  Timer? _callTimer;
  int _callDurationSeconds = 0;
  String callDurationString = '00:00';

  String localUserName = 'Guest';
  String remoteUserName = 'Peer';

  // Renderers are created once and kept alive for the app lifetime.
  // They must never be disposed while the Provider is alive.
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  String roomId = '';
  String connectionState = 'new';
  bool isMuted = false;
  bool isCameraOff = false;
  bool isRemoteCameraOff = false;
  bool isRemoteMuted = false;
  bool isScreenSharing = false;
  bool hasRemoteStream = false;
  bool isInitialized = false;
  bool isHost = false;
  bool hasCamera = true;
  bool isFrontCamera = true;
  String statusMessage = 'Waiting for connection...';
  String userId = '';
  bool _handlingPeerLeft = false;

  bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  // Buffer ICE candidates received before remote description is set
  final List<Map<String, dynamic>> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;

  // Guard: remote stream assigned only once per session
  MediaStream? _remoteStream;
  // final bool _isCreator = false;
  // final bool _isLeavingCall = false;
  Future<void>? _renderersInitialization;

  WebRTCService({required this.signalingService}) {
    _initRenderers();
    _wireSignalingCallbacks();
    WidgetsBinding.instance.addObserver(this);
    AppLifecycleHelper.registerUnloadHandler(() {
      leaveCall();
    });
  }

  Future<void> _initRenderers() async {
    _renderersInitialization ??= _doInitRenderers();
    await _renderersInitialization;
  }

  Future<void> _doInitRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void _wireSignalingCallbacks() {
    signalingService.onConnect = () {
      statusMessage = 'Connected';
      notifyListeners();
    };
    signalingService.onDisconnect = (reason) {
      statusMessage = 'Signaling error: $reason';
      notifyListeners();
    };
    signalingService.onUserJoined = (incomingRoomId) async {
      try {
        final activeRoomId = incomingRoomId.isNotEmpty ? incomingRoomId : roomId;
        statusMessage = 'Peer joined — creating offer';
        notifyListeners();
        if (_peerConnection == null) await _createPeerConnection();
        await _createOffer(roomId: activeRoomId); // ← pass explicitly
      } catch (e) {
        statusMessage = 'Error on user joined: $e';
        notifyListeners();
      }
    };
    signalingService.onOffer = (data, incomingRoomId) async {
      try {
        final activeRoomId = incomingRoomId.isNotEmpty ? incomingRoomId : roomId;
        if (_peerConnection == null) await _createPeerConnection();
        await _handleRemoteOffer(data, roomId: activeRoomId); // ← pass explicitly
      } catch (e) {
        statusMessage = 'Error on offer: $e';
        notifyListeners();
        debugPrint('Error in onOffer callback: $e');
      }
    };
    signalingService.onAnswer = (data, incomingRoomId) async {
      try {
        await _handleRemoteAnswer(data, roomId: incomingRoomId);
      } catch (e) {
        statusMessage = 'Error on answer: $e';
        notifyListeners();
      }
    };
    signalingService.onIceCandidate = (data) async {
      try {
        await _handleRemoteIceCandidate(data);
      } catch (e) {
        debugPrint('Error in onIceCandidate callback: $e');
      }
    };
    signalingService.onUserLeft = () {
      _handlePeerLeft();
      // unawaited(_handlePeerLeft());
    };
  }

  Future<void> initialize(String roomId, {required bool createRoom, required String userId}) async {
    await _initRenderers();
    // Reset state fully so re-entering a room works correctly
    if (isInitialized) await _resetSession();

    isInitialized = true;
    statusMessage = 'Preparing camera...';
    notifyListeners();

    this.roomId = roomId;
    this.userId = userId;
    isHost = createRoom;

    if (!createRoom) {
      try {
        final joinError = await signalingService.getJoinableRoomError(roomId, userId);
        if (joinError != null) {
          statusMessage = joinError;
          isInitialized = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        statusMessage = 'Could not verify room: $e';
        isInitialized = false;
        notifyListeners();
        return;
      }
    }

    try {
      await _initLocalMedia();
    } catch (e) {
      // Camera/mic permission denied or hardware error
      statusMessage = 'Camera error: $e';
      isInitialized = false;
      notifyListeners();
      return;
    }

    await _createPeerConnection();
    await signalingService.joinRoom(roomId, createRoom: createRoom, userId: userId);

    statusMessage = 'Joined room $roomId';
    notifyListeners();
  }

  void setLocalUserIdentity(String name) {
    if (name.trim().isNotEmpty) {
      localUserName = name;
      notifyListeners();
    }
  }

  Future<void> _resetSession() async {
    await _initRenderers();
    _pendingCandidates.clear();
    _remoteDescriptionSet = false;
    _remoteStream = null;
    hasRemoteStream = false;
    roomId = '';
    isHost = false;
    isFrontCamera = true;

    _dataChannel?.close();
    _dataChannel = null;
    chatMessages.clear();
    polls.clear();
    hasUnreadMessages = false;

    _stopTimer();

    _videoSender = null;
    final pc = _peerConnection;
    _peerConnection = null;
    await pc?.close();

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    await Future.delayed(const Duration(milliseconds: 100));

    await _disposeScreenShareStream();
    if (_localStream != null) {
      final tracks = List<MediaStreamTrack>.from(_localStream!.getTracks());
      for (final track in tracks) {
        track.stop();
      }
      await _localStream!.dispose();
    }
    _localStream = null;
    _cameraStream = null;

    signalingService.disconnect();
  }

  Future<void> _handlePeerLeft() async {
    if (_handlingPeerLeft) return;
    _handlingPeerLeft = true;

    try {
      final currentRoomId = roomId;
      final currentUserId = userId;

      _remoteStream?.getTracks().forEach((track) => track.stop());
      _remoteStream?.dispose();
      _remoteStream = null;
      remoteRenderer.srcObject = null;
      hasRemoteStream = false;

      _dataChannel?.close();
      _dataChannel = null;
      chatMessages.clear();
      polls.clear();
      hasUnreadMessages = false;

      _stopTimer();

      final pc = _peerConnection;
      _peerConnection = null;
      await pc?.close();

      _remoteDescriptionSet = false;
      _pendingCandidates.clear();
      _videoSender = null;

      signalingService.resetForRejoin();
      signalingService.reattachListener(roomId); // ← re-attach with clean state

      // ← restore room context explicitly
      roomId = currentRoomId;
      userId = currentUserId;

      connectionState = 'waiting';
      statusMessage = 'Peer left. Waiting for someone to join...';
      notifyListeners();

      await _createPeerConnection();
      onPeerLeft?.call();
    } finally {
      _handlingPeerLeft = false;
    }
  }

  Future<void> _initLocalMedia() async {
    // Stop any previous tracks before requesting new ones
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream?.dispose();
    _localStream = null;
    _cameraStream = null;

    try {
      // Attempt to get both audio and video
      try {
        _cameraStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
        });
        isCameraOff = false;
        hasCamera = true;
      } catch (e) {
        debugPrint('Detailed getUserMedia failed: $e. Trying simple camera constraints.');
        _cameraStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
        isCameraOff = false;
        hasCamera = true;
      }
    } catch (e) {
      // Log the error for debugging
      debugPrint('Camera not available, falling back to audio only: $e');
      try {
        _cameraStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
        isCameraOff = true;
        hasCamera = false;
      } catch (audioErr) {
        debugPrint('Audio and video not available/denied. Falling back to empty stream: $audioErr');
        try {
          _cameraStream = await createLocalMediaStream('local_stream');
          isCameraOff = true;
          hasCamera = false;
        } catch (streamErr) {
          debugPrint('Failed to create empty stream: $streamErr');
          rethrow;
        }
      }
    }

    _localStream = _cameraStream;
    localRenderer.srcObject = _localStream;
    isMuted = _localStream?.getAudioTracks().isEmpty ?? true;
    isScreenSharing = false;
    isFrontCamera = true;
    notifyListeners();
  }

  Future<void> _createPeerConnection() async {
    final pc = _peerConnection;
    _peerConnection = null;
    await pc?.close();
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
        signalingService.sendIceCandidate(roomId, {'candidate': candidate.candidate, 'sdpMid': candidate.sdpMid, 'sdpMLineIndex': candidate.sdpMLineIndex?.toString()});
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      connectionState = state.name;
      final stateText = state == RTCIceConnectionState.RTCIceConnectionStateConnected
          ? 'connected'
          : state == RTCIceConnectionState.RTCIceConnectionStateClosed
          ? 'disconnected'
          : state.name;
      statusMessage = '$remoteUserName is $stateText';
      notifyListeners();
    };

    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _dataChannel = channel;
      _wireDataChannel();
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) async {
      // Ignore local tracks if they trigger onTrack
      if (_localStream != null) {
        final localTracks = _localStream!.getTracks();
        if (localTracks.any((t) => t.id == event.track.id)) {
          return;
        }
      }

      // onTrack fires once per track (audio + video separately).
      // Use the stream from the event when available; otherwise build one.
      if (event.streams.isNotEmpty) {
        final incoming = event.streams[0];
        // Only assign once — reassigning on the audio track event would
        // re-snapshot the stream before the video track arrives on some browsers.
        if (_remoteStream == null) {
          _remoteStream = incoming;
          remoteRenderer.srcObject = incoming;
          hasRemoteStream = true;
          statusMessage = '$remoteUserName is connected';
          _startTimer();
          notifyListeners();
        }
      } else {
        // Fallback for browsers that deliver tracks without a stream wrapper
        _remoteStream ??= await createLocalMediaStream(event.track.id ?? 'remote');
        await _remoteStream!.addTrack(event.track);
        // Re-assign after adding each track so the renderer copies it
        remoteRenderer.srcObject = _remoteStream;
        if (!hasRemoteStream) {
          hasRemoteStream = true;
          statusMessage = '$remoteUserName is connected';
          _startTimer();
        }
        notifyListeners();
      }
    };

    // Add all local tracks to the peer connection
    bool hasLocalAudio = false;
    bool hasLocalVideo = false;
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        final sender = await _peerConnection!.addTrack(track, _localStream!);
        if (track.kind == 'video') {
          _videoSender = sender;
          hasLocalVideo = true;
        } else if (track.kind == 'audio') {
          hasLocalAudio = true;
        }
      }
    }

    // Pre-negotiate audio transceiver if no local audio track is present
    if (!hasLocalAudio && _peerConnection != null) {
      try {
        await _peerConnection!.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
        );
      } catch (e) {
        debugPrint('Failed to add audio transceiver: $e');
      }
    }

    // If no local video track was added (e.g. no camera), add a video transceiver
    // so we can send video (like screen sharing) later without renegotiation.
    if (!hasLocalVideo && _peerConnection != null) {
      try {
        final transceiver = await _peerConnection!.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
        );
        _videoSender = transceiver.sender;
      } catch (e) {
        debugPrint('Failed to add video transceiver: $e');
      }
    }
  }

  Future<void> _createOffer({String? roomId}) async {
    final targetRoom = roomId ?? this.roomId; // ← use passed value or fallback
    try {
      if (_peerConnection == null) return;

      _dataChannel = await _peerConnection!.createDataChannel('chat', RTCDataChannelInit());
      _wireDataChannel();

      final offer = await _peerConnection!.createOffer({'offerToReceiveAudio': true, 'offerToReceiveVideo': true});
      await _peerConnection!.setLocalDescription(offer);
      await signalingService.sendOffer(targetRoom, {'sdp': offer.sdp, 'type': offer.type});
      statusMessage = 'Offer sent — waiting for answer';
      notifyListeners();
      // In WebRTCService._createOffer(), after sending:
      Future.delayed(const Duration(seconds: 10), () async {
        if (!_remoteDescriptionSet && _peerConnection != null) {
          debugPrint('No answer received, retrying offer...');
          await _createOffer(); // retry once
        }
      });
    } catch (e) {
      statusMessage = 'Create offer failed: $e';
      notifyListeners();
      debugPrint('Create offer failed: $e');
      rethrow;
    }
  }

  Future<void> _handleRemoteOffer(Map<String, dynamic> data, {String? roomId}) async {
    final targetRoom = roomId ?? this.roomId;
    try {
      if (_peerConnection == null) return;
      if (targetRoom.isEmpty) {
        debugPrint('_handleRemoteOffer SKIPPED — roomId empty');
        return;
      }

      await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'] as String, data['type'] as String));
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      await signalingService.sendAnswer(
        targetRoom, // ← use captured roomId
        {'sdp': answer.sdp, 'type': answer.type},
      );
      statusMessage = 'Answer sent';
      notifyListeners();
    } catch (e) {
      statusMessage = 'Handle remote offer failed: $e';
      notifyListeners();
      debugPrint('Handle remote offer failed: $e');
      rethrow;
    }
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> data, {String? roomId}) async {
    final targetRoom = roomId ?? this.roomId;
    debugPrint('_handleRemoteAnswer → roomId: "$targetRoom"');
    try {
      if (_peerConnection == null) return;
      final state = _peerConnection!.signalingState;
      if (state == RTCSignalingState.RTCSignalingStateStable || state == RTCSignalingState.RTCSignalingStateClosed) return;

      await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'] as String, data['type'] as String));
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();
      statusMessage = 'Peer answered';
      notifyListeners();
    } catch (e) {
      statusMessage = 'Handle remote answer failed: $e';
      notifyListeners();
      debugPrint('Handle remote answer failed: $e');
      rethrow;
    }
  }

  Future<void> _handleRemoteIceCandidate(Map<String, dynamic> data) async {
    if (_peerConnection == null) return;

    if (!_remoteDescriptionSet) {
      _pendingCandidates.add(data);
      return;
    }

    await _addCandidate(data);
  }

  Future<void> _addCandidate(Map<String, dynamic> data) async {
    final candidate = data['candidate'] as String?;
    final sdpMid = data['sdpMid'] as String?;
    // sdpMLineIndex stored as String to avoid Firestore num/int mismatch
    final rawIndex = data['sdpMLineIndex'];
    final sdpMLineIndex = rawIndex != null ? int.tryParse(rawIndex.toString()) : null;

    if (candidate == null || candidate.isEmpty) return;

    debugPrint('Adding ICE candidate: $sdpMid / $sdpMLineIndex');

    try {
      await _peerConnection!.addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
    } catch (e) {
      debugPrint('addCandidate failed: $e');
    }
  }

  Future<void> _flushPendingCandidates() async {
    final toFlush = List<Map<String, dynamic>>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final c in toFlush) {
      await _addCandidate(c);
    }
  }

  void _wireDataChannel() {
    _dataChannel?.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) return;

      try {
        final Map<String, dynamic> data = jsonDecode(message.text);
        final String type = data['type'] ?? 'chat';

        if (type == 'identity') {
          remoteUserName = data['payload'] ?? 'Peer';
          if (data.containsKey('isCameraOff')) {
            isRemoteCameraOff = data['isCameraOff'];
          }
          if (data.containsKey('isMuted')) {
            isRemoteMuted = data['isMuted'];
          }
          statusMessage = '$remoteUserName connected';
          notifyListeners();
          return;
        }

        if (type == 'camera_state') {
          isRemoteCameraOff = data['payload'] ?? false;
          notifyListeners();
          return;
        }

        if (type == 'mic_state') {
          isRemoteMuted = data['payload'] ?? false;
          notifyListeners();
          return;
        }

        // 1. UPDATE REACTION PARSING TO EXTRACT SENDER NAME
        if (type == 'reaction') {
          final String emoji = data['payload'] ?? '';
          final String sender = data['senderName'] ?? remoteUserName;
          if (emoji.isNotEmpty) {
            onNewReaction?.call(emoji, sender);
          }
          return;
        }

        if (type == 'chat') {
          final String text = data['payload'] ?? '';
          final String sender = data['sender'] ?? remoteUserName;
          if (text.isNotEmpty) {
            final msg = ChatMessage(sender: sender, text: text, timestamp: DateTime.now());
            chatMessages.add(msg);
            hasUnreadMessages = true;
            onNewMessage?.call(msg);
            notifyListeners();
          }
          return;
        }

        // Poll creation
        if (type == 'poll') {
          final poll = PollMessage.fromJson(Map<String, dynamic>.from(data['payload'] as Map));
          polls.add(poll);
          hasUnreadMessages = true;
          onNewPoll?.call(poll);
          notifyListeners();
          return;
        }

        // Poll vote from remote peer
        if (type == 'poll_vote') {
          final String pollId = data['pollId'] as String? ?? '';
          final int optionIndex = (data['optionIndex'] as num?)?.toInt() ?? -1;
          final poll = polls.firstWhere(
            (p) => p.pollId == pollId,
            orElse: () => PollMessage(pollId: '', question: '', options: [], sender: ''),
          );
          if (poll.pollId.isNotEmpty && optionIndex >= 0) {
            if (optionIndex < poll.votes.length) {
              poll.votes[optionIndex]++;
            }
            notifyListeners();
          }
          return;
        }

        // Unknown type – ignore safely
      } catch (e) {
        final msg = ChatMessage(sender: remoteUserName, text: message.text, timestamp: DateTime.now());
        chatMessages.add(msg);
        hasUnreadMessages = true;
        onNewMessage?.call(msg);
        notifyListeners();
      }
    };
    _dataChannel?.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _sendLocalIdentity();
        notifyListeners();
      }
    };
  }

  void sendReaction(String emoji) {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'reaction', 'payload': emoji, 'senderName': localUserName});
      _dataChannel!.send(RTCDataChannelMessage(payload));
      onNewReaction?.call(emoji, 'Me');
    }
  }

  void _sendLocalIdentity() {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'identity', 'payload': localUserName, 'isCameraOff': isCameraOff, 'isMuted': isMuted});
      _dataChannel!.send(RTCDataChannelMessage(payload));
      debugPrint('Identity synced: $localUserName');
    }
  }

  void _sendCameraState() {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'camera_state', 'payload': isCameraOff});
      _dataChannel!.send(RTCDataChannelMessage(payload));
    }
  }

  void sendMessage(String text) {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'chat', 'payload': text, 'sender': localUserName});
      _dataChannel!.send(RTCDataChannelMessage(payload));
      chatMessages.add(ChatMessage(sender: localUserName, text: text, timestamp: DateTime.now()));
      notifyListeners();
    }
  }

  /// Create a new poll and broadcast it over the data channel.
  void sendPoll(String question, List<String> options) {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) return;
    final poll = PollMessage(pollId: DateTime.now().millisecondsSinceEpoch.toString(), question: question, options: options, sender: localUserName);
    polls.add(poll);
    final payload = jsonEncode({'type': 'poll', 'payload': poll.toJson()});
    _dataChannel!.send(RTCDataChannelMessage(payload));
    hasUnreadMessages = false; // creator sees it immediately
    notifyListeners();
  }

  /// Submit a vote for [optionIndex] on the poll with [pollId].
  void voteOnPoll(String pollId, int optionIndex) {
    final poll = polls.firstWhere(
      (p) => p.pollId == pollId,
      orElse: () => PollMessage(pollId: '', question: '', options: [], sender: ''),
    );
    if (poll.pollId.isEmpty) return;
    if (poll.localVotedIndex == optionIndex) return;
    poll.vote(optionIndex);
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'poll_vote', 'pollId': pollId, 'optionIndex': optionIndex});
      _dataChannel!.send(RTCDataChannelMessage(payload));
    }
    notifyListeners();
  }

  void markChatAsRead() {
    if (hasUnreadMessages) {
      hasUnreadMessages = false;
      notifyListeners();
    }
  }

  void _sendMicState() {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final payload = jsonEncode({'type': 'mic_state', 'payload': isMuted});
      _dataChannel!.send(RTCDataChannelMessage(payload));
    }
  }

  Future<void> toggleMute() async {
    final tracks = _localStream?.getAudioTracks();
    if (tracks == null || tracks.isEmpty) return;
    isMuted = !isMuted;
    tracks.first.enabled = !isMuted;
    statusMessage = isMuted ? 'Microphone muted' : 'Microphone on';
    _sendMicState();
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    if (isCameraOff) {
      await _enableCamera();
    } else {
      await _disableCamera();
    }
  }

  Future<void> _enableCamera() async {
    try {
      MediaStream? videoStream;
      int retryCount = 0;

      // Retry getUserMedia to give the native OS time to fully release the hardware
      while (videoStream == null && retryCount < 2) {
        try {
          videoStream = await navigator.mediaDevices.getUserMedia({
            'audio': false,
            'video': {
              'facingMode': isFrontCamera ? 'user' : 'environment',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
            },
          });
        } catch (e) {
          debugPrint('getUserMedia detailed constraints failed (attempt ${retryCount + 1}): $e');
          retryCount++;
          if (retryCount < 2) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
      }

      if (videoStream == null) {
        debugPrint('Detailed constraints failed. Trying simple constraints.');
        videoStream = await navigator.mediaDevices.getUserMedia({'audio': false, 'video': true});
      }

      final videoTrack = videoStream.getVideoTracks().first;

      // Ensure we clean up any old video tracks first
      if (_localStream != null) {
        final existingVideoTracks = List<MediaStreamTrack>.from(_localStream!.getVideoTracks());
        for (final track in existingVideoTracks) {
          try {
            await _localStream!.removeTrack(track);
          } catch (e) {
            debugPrint('Error removing track: $e');
          }
          try {
            track.stop();
          } catch (e) {
            debugPrint('Error stopping track: $e');
          }
        }
        await _localStream!.addTrack(videoTrack);
      }

      // Replace track in peer connection if connected
      if (_videoSender != null) {
        await _videoSender!.replaceTrack(videoTrack);
      } else {
        final senders = await _peerConnection?.getSenders();
        if (senders != null && senders.isNotEmpty) {
          for (final s in senders) {
            if (s.track?.kind == 'video') {
              _videoSender = s;
              break;
            }
          }
          if (_videoSender != null) {
            await _videoSender!.replaceTrack(videoTrack);
          } else if (_peerConnection != null && _localStream != null) {
            _videoSender = await _peerConnection!.addTrack(videoTrack, _localStream!);
          }
        }
      }

      localRenderer.srcObject = null;
      await Future.delayed(const Duration(milliseconds: 50));
      localRenderer.srcObject = _localStream;
      isCameraOff = false;
      hasCamera = true;
      _sendCameraState();
      statusMessage = 'Camera on';
      notifyListeners();
    } catch (e) {
      debugPrint('Enable camera failed: $e');
      isCameraOff = true;
      statusMessage = 'Camera not available';
      notifyListeners();
    }
  }

  Future<void> _disableCamera() async {
    // 1. Clear local renderer first to detach the surface texture from the camera session
    localRenderer.srcObject = null;
    await Future.delayed(const Duration(milliseconds: 100)); // Short delay to let surface detach

    // Stop and remove video tracks from local stream — releases hardware immediately
    if (_localStream != null) {
      final localVideoTracks = List<MediaStreamTrack>.from(_localStream!.getVideoTracks());
      for (final track in localVideoTracks) {
        try {
          await _localStream!.removeTrack(track);
        } catch (e) {
          debugPrint('Error removing track: $e');
        }
        try {
          track.stop();
        } catch (e) {
          debugPrint('Error stopping track: $e');
        }
      }
    }

    // Null out video sender track in peer connection
    if (_videoSender != null) {
      await _videoSender!.replaceTrack(null);
    } else {
      final senders = await _peerConnection?.getSenders();
      if (senders != null) {
        for (final sender in senders) {
          if (sender.track?.kind == 'video') {
            _videoSender = sender;
            await sender.replaceTrack(null);
            break;
          }
        }
      }
    }

    localRenderer.srcObject = null;
    isCameraOff = true;
    _sendCameraState();
    statusMessage = 'Camera off';
    notifyListeners();
  }

  int _cameraIndex = 0;

  bool get _isMobileWeb => kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> switchCamera() async {
    if (isScreenSharing) {
      statusMessage = 'Stop screen sharing before switching camera';
      notifyListeners();
      return;
    }

    if (isCameraOff) {
      isFrontCamera = !isFrontCamera;
      _cameraIndex = (_cameraIndex + 1); // keep index in sync for web
      notifyListeners();
      return;
    }

    if (kIsWeb) {
      try {
        final devices = await navigator.mediaDevices.enumerateDevices();
        final videoDevices = devices.where((d) => d.kind == 'videoinput').toList();
        if (videoDevices.length < 2) {
          statusMessage = 'No other camera found';
          notifyListeners();
          return;
        }

        _cameraIndex = (_cameraIndex + 1) % videoDevices.length;
        final nextDevice = videoDevices[_cameraIndex];

        final label = nextDevice.label.toLowerCase();
        final nextIsFront = label.contains('front') || label.contains('user') || label.contains('facetime') || label.contains('selfie');

        final newStream = await navigator.mediaDevices.getUserMedia({
          'audio': false,
          'video': {'deviceId': nextDevice.deviceId},
        });

        final newTrack = newStream.getVideoTracks().first;

        // ← safely get old track, may not exist if camera was just enabled
        final oldTrack = _cameraStream?.getVideoTracks().firstOrNull;
        if (oldTrack != null) {
          await _cameraStream?.removeTrack(oldTrack);
          oldTrack.stop();
        }
        await _cameraStream?.addTrack(newTrack);
        _localStream = _cameraStream;
        localRenderer.srcObject = _localStream;

        // ← use cached sender or find it
        if (_videoSender != null) {
          await _videoSender!.replaceTrack(newTrack);
        } else {
          final transceivers = await _peerConnection?.getTransceivers();
          if (transceivers != null) {
            for (final t in transceivers) {
              if (t.receiver.track?.kind == 'video') {
                _videoSender = t.sender;
                await _videoSender!.replaceTrack(newTrack);
                break;
              }
            }
          }
        }

        isFrontCamera = nextIsFront;
        statusMessage = 'Camera switched';
        notifyListeners();

        // // Delay updating mirroring state to let the stream transition first
        // Future.delayed(const Duration(milliseconds: 400), () {
        //   isFrontCamera = nextIsFront;
        //   notifyListeners();
        // });
      } catch (e) {
        statusMessage = 'Camera switch failed';
        notifyListeners();
      }
    } else {
      final tracks = _cameraStream?.getVideoTracks();
      if (tracks == null || tracks.isEmpty) return;
      await Helper.switchCamera(tracks.first);

      // Delay changing the mirroring flag to let the hardware switch first
      Future.delayed(const Duration(milliseconds: 400), () {
        isFrontCamera = !isFrontCamera;
        statusMessage = 'Camera switched';
        notifyListeners();
      });
    }
  }

  bool get canScreenShare => (kIsWeb && !_isMobileWeb) || WebRTC.platformIsAndroid;

  Future<void> toggleScreenShare() async {
    if (isScreenSharing) {
      await stopScreenShare();
      return;
    }

    await startScreenShare();
  }

  Future<void> startScreenShare() async {
    if (!canScreenShare) {
      statusMessage = _isMobileWeb
          ? 'Screen sharing is not supported in phone browsers. Use the Android app or desktop browser.'
          : 'Screen sharing is not available on this platform';
      notifyListeners();
      return;
    }
    // || _cameraStream == null
    if (_peerConnection == null) {
      statusMessage = 'Join a call before starting screen share';
      notifyListeners();
      return;
    }

    try {
      // The foreground service (type: mediaProjection) MUST be running before
      // getDisplayMedia() starts capturing. On Android 10+ flutter_webrtc calls
      // MediaProjection.createVirtualDisplay() synchronously inside getDisplayMedia,
      // and that throws a SecurityException (crashing the app) if no mediaProjection
      // foreground service is active yet.
      await _prepareAndroidScreenShare();

      final displayStream = await navigator.mediaDevices.getDisplayMedia({
        'audio': false,
        'video': kIsWeb
            ? {
                'frameRate': 30,
                'width': {'ideal': 1920},
                'height': {'ideal': 1080},
              }
            : true,
      });

      final videoTracks = displayStream.getVideoTracks();
      if (videoTracks.isEmpty) {
        await displayStream.dispose();
        statusMessage = 'No screen track received';
        notifyListeners();
        return;
      }

      final screenTrack = videoTracks.first;
      screenTrack.onEnded = () {
        if (isScreenSharing) {
          stopScreenShare();
        }
      };

      await _replaceOrAddOutgoingVideoTrack(screenTrack);

      _screenShareStream = displayStream;
      _localStream = displayStream;
      localRenderer.srcObject = displayStream;
      isScreenSharing = true;
      statusMessage = 'Screen sharing started';
      notifyListeners();
    } catch (e) {
      // Clean up the foreground service if capture never started
      // (e.g. user dismissed the screen-capture permission dialog).
      await _disposeScreenShareStream();
      isScreenSharing = false;
      statusMessage = 'Screen sharing failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopScreenShare() async {
    if (!isScreenSharing) return;

    final cameraTracks = _cameraStream?.getVideoTracks() ?? [];

    if (cameraTracks.isNotEmpty && !isCameraOff) {
      // ← has camera and it's on: restore camera track
      final cameraTrack = cameraTracks.first;
      await _replaceOrAddOutgoingVideoTrack(cameraTrack);
      _localStream = _cameraStream;
      localRenderer.srcObject = _cameraStream;
    } else {
      // ← no camera or camera is off: remove video track entirely
      if (_videoSender != null) {
        await _videoSender!.replaceTrack(null);
      } else {
        final transceivers = await _peerConnection?.getTransceivers();
        if (transceivers != null) {
          for (final t in transceivers) {
            if (t.receiver.track?.kind == 'video') {
              _videoSender = t.sender;
              await _videoSender!.replaceTrack(null); // ← send no video
              break;
            }
          }
        }
      }
      // restore local stream to audio-only stream
      _localStream = _cameraStream; // audio-only stream
      localRenderer.srcObject = _localStream;
    }

    await _disposeScreenShareStream();
    isScreenSharing = false;
    statusMessage = 'Screen sharing stopped';
    notifyListeners();
  }

  Future<void> _replaceOrAddOutgoingVideoTrack(MediaStreamTrack newTrack) async {
    // 1. If we have a cached video sender, try to use it
    if (_videoSender != null) {
      await _videoSender!.replaceTrack(newTrack);
      return;
    }

    // 2. If not cached, look for a video transceiver
    final transceivers = await _peerConnection?.getTransceivers();
    if (transceivers != null) {
      for (final t in transceivers) {
        if (t.receiver.track?.kind == 'video') {
          _videoSender = t.sender;
          await _videoSender!.replaceTrack(newTrack);
          return;
        }
      }
    }

    // 3. Fallback: look for a sender whose track is video
    final senders = await _peerConnection?.getSenders();
    if (senders != null) {
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          _videoSender = sender;
          await sender.replaceTrack(newTrack);
          return;
        }
      }
    }

    // 4. No video transceiver/sender exists (fallback)
    final streamRef = _localStream ?? _cameraStream;
    if (streamRef != null && _peerConnection != null) {
      _videoSender = await _peerConnection!.addTrack(newTrack, streamRef);
    }
  }

  Future<void> _disposeScreenShareStream() async {
    _screenShareStream?.getTracks().forEach((track) => track.stop());
    await _screenShareStream?.dispose();
    _screenShareStream = null;

    if (WebRTC.platformIsAndroid && FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
    }
  }

  Future<void> _prepareAndroidScreenShare() async {
    if (!WebRTC.platformIsAndroid) return;

    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'CodeX Meet screen sharing',
      notificationText: 'Your screen is being shared in an active meeting.',
      notificationImportance: AndroidNotificationImportance.normal,
      notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
    );

    final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
    if (!initialized) {
      throw Exception('Foreground service permission was denied');
    }

    if (!FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }

  Future<void> leaveCall() async {
    await signalingService.leaveRoom(roomId, userId);
    await _resetSession();
    isInitialized = false;
    statusMessage = 'Left meeting';
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    _disposeScreenShareStream();
    _peerConnection?.dispose();
    signalingService.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      leaveCall();
    }
  }

  void _startTimer() {
    if (_callTimer != null && _callTimer!.isActive) return;
    _callTimer?.cancel();
    _callDurationSeconds = 0;
    callDurationString = '00:00';
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      final hours = (_callDurationSeconds ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((_callDurationSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (_callDurationSeconds % 60).toString().padLeft(2, '0');
      callDurationString = hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
      notifyListeners();
    });
  }

  void _stopTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _callDurationSeconds = 0;
    callDurationString = '00:00:00';
  }
}
