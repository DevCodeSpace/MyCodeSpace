import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore-based signaling service for WebRTC.
/// Role assignment: first peer to create the room is the "caller" (sends offer).
/// Second peer is the "callee" (receives offer, sends answer).
class FirebaseSignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _rooms = 'rooms';
  static const String _callerCandidates = 'callerCandidates';
  static const String _calleeCandidates = 'calleeCandidates';
  static const String _roleCaller = 'caller';
  static const String _roleCallee = 'callee';

  bool _isCaller = false;
  bool _offerCreated = false; // guard: caller only sends offer once
  bool _answerHandled = false; // guard: caller only handles answer once
  bool _offerHandled = false; // guard: callee only handles offer once
  bool _peerJoined = false;
  bool _peerLeftHandled = false;
  bool _isDisconnected = false;

  StreamSubscription? _roomSubscription;
  StreamSubscription? _candidateSubscription;

  // Callbacks — set by WebRTCService before calling joinRoom
  void Function()? onConnect;
  void Function(String roomId)? onUserJoined;
  void Function()? onUserLeft;
  void Function(Map<String, dynamic> offer, String roomId)? onOffer;
  void Function(Map<String, dynamic> answer, String roomId)? onAnswer;
  void Function(Map<String, dynamic> candidate)? onIceCandidate;
  void Function(String reason)? onDisconnect;

  Future<String?> getJoinableRoomError(String roomId, String userId) async {
    final roomDoc = await _firestore.collection(_rooms).doc(roomId).get(const GetOptions(source: Source.server));
    return _getJoinableRoomError(roomDoc.exists ? roomDoc.data() : null, userId);
  }

  Future<void> _clearSubcollection(DocumentReference<Map<String, dynamic>> roomRef, String collectionName) async {
    final docs = await roomRef.collection(collectionName).get();
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> joinRoom(String roomId, {required bool createRoom, required String userId}) async {
    debugPrint('--> [joinRoom] Initiated. Room ID: $roomId, User ID: $userId, createRoom: $createRoom');
    _isDisconnected = false;

    try {
      final roomRef = _firestore.collection(_rooms).doc(roomId);
      debugPrint('[joinRoom] Fetching room document from server...');
      final roomDoc = await roomRef.get(const GetOptions(source: Source.server));
      final roomData = roomDoc.exists ? roomDoc.data() : null;
      debugPrint('[joinRoom] Room exists: ${roomDoc.exists}');

      if (createRoom) {
        debugPrint('[joinRoom] Branch: Force Create Room.');
        _isCaller = true;
        if (roomDoc.exists) {
          debugPrint('[joinRoom] Room already existed. Clearing candidates before recreation...');
          await _clearRoomCandidates(roomRef);
        }

        debugPrint('[joinRoom] Setting initial room data...');
        await roomRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'callerJoined': true,
          'calleeJoined': false,
          'callEnded': false,
          'endedBy': null,
          'endedAt': null,
          'callerId': userId,
        });

        debugPrint('[joinRoom] Room created successfully. Starting callee listener.');
        _listenForCallee(roomId);
        onConnect?.call();
        return;
      }

      if (roomData == null) {
        debugPrint('[joinRoom] Error: Room data is null.');
        throw Exception('Room ID does not exist.');
      }

      final callerId = roomData['callerId'] as String?;
      final callerJoined = roomData['callerJoined'] == true;
      final calleeJoined = roomData['calleeJoined'] == true;

      debugPrint('[joinRoom] Room Info - CallerID: $callerId, CallerJoined: $callerJoined, CalleeJoined: $calleeJoined');

      // Caller rejoining their own room
      if (userId == callerId) {
        debugPrint('[joinRoom] Branch: Caller rejoining their own room.');
        _isCaller = true;
        _peerJoined = calleeJoined;

        debugPrint('[joinRoom] Clearing existing candidates for fresh sync...');
        await _clearSubcollection(roomRef, _callerCandidates);
        await _clearSubcollection(roomRef, _calleeCandidates);

        debugPrint('[joinRoom] Updating room doc (deleting old offer/answer)...');
        await roomRef.update({'callerJoined': true, 'callEnded': false, 'endedBy': null, 'endedAt': null, 'offer': FieldValue.delete(), 'answer': FieldValue.delete()});

        _listenForCallee(roomId);
        onConnect?.call();
        return;
      }

      if (callerJoined && calleeJoined) {
        debugPrint('[joinRoom] Error: Room is completely full (caller & callee already active).');
        throw Exception('This room already has two participants.');
      }

      if (callerJoined) {
        // New callee joining (any user)
        debugPrint('[joinRoom] Branch: New Callee joining an active caller room.');
        _isCaller = false;
        _peerJoined = true;

        debugPrint('[joinRoom] Clearing old callee candidates...');
        await _clearSubcollection(roomRef, _calleeCandidates);

        debugPrint('[joinRoom] Updating room data (forcing fresh offer/answer)...');
        await roomRef.update({'calleeJoined': true, 'callEnded': false, 'endedBy': null, 'endedAt': null, 'offer': FieldValue.delete(), 'answer': FieldValue.delete()});

        _listenForOffer(roomId);
        onConnect?.call();
      } else if (calleeJoined) {
        // Caller joining when callee is already waiting
        debugPrint('[joinRoom] Branch: Caller joining a room where Callee is already waiting.');
        _isCaller = true;
        _peerJoined = true;

        debugPrint('[joinRoom] Clearing old caller candidates...');
        await _clearSubcollection(roomRef, _callerCandidates);

        debugPrint('[joinRoom] Updating room data as Caller...');
        await roomRef.update({'callerJoined': true, 'callEnded': false, 'endedBy': null, 'endedAt': null, 'callerId': userId});

        _listenForCallee(roomId);
        onConnect?.call();
      } else {
        // Empty room, join as caller
        debugPrint('[joinRoom] Branch: Room is completely empty. Joining as original Caller.');
        _isCaller = true;

        debugPrint('[joinRoom] Clearing room candidates...');
        await _clearRoomCandidates(roomRef);

        debugPrint('[joinRoom] Resetting room schema...');
        await roomRef.update({
          'callerJoined': true,
          'calleeJoined': false,
          'callEnded': false,
          'endedBy': null,
          'endedAt': null,
          'offer': FieldValue.delete(),
          'answer': FieldValue.delete(),
          'callerId': userId,
        });

        _listenForCallee(roomId);
        onConnect?.call();
      }
      debugPrint('<-- [joinRoom] Completed successfully.');
    } catch (e, stacktrace) {
      debugPrint('[joinRoom] CRITICAL ERROR: $e');
      debugPrint('[joinRoom] Stacktrace: $stacktrace');
      onDisconnect?.call('Failed to join room: $e');
      rethrow;
    }
  }

  void reattachListener(String roomId) {
    if (_isCaller) {
      _listenForCallee(roomId);
    } else {
      _listenForOffer(roomId);
    }
  }

  // Caller listens here: waits for callee join → creates offer once, then waits for answer
  void _listenForCallee(String roomId) {
    _roomSubscription?.cancel();
    _candidateSubscription?.cancel();

    // ← reset handler guards every time listener is re-attached
    _offerCreated = false;
    _answerHandled = false;
    _peerLeftHandled = false;

    final roomRef = _firestore.collection(_rooms).doc(roomId);

    // ← candidate listener FIRST
    _candidateSubscription = roomRef.collection(_calleeCandidates).snapshots().listen((snapshot) {
      try {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final d = change.doc.data();
            if (d != null) onIceCandidate?.call(d);
          }
        }
      } catch (e) {
        debugPrint('Error in callee candidates snapshot: $e');
      }
    });

    _roomSubscription = roomRef.snapshots(includeMetadataChanges: true).listen((snapshot) {
      try {
        if (!snapshot.exists) {
          _notifyPeerLeft();
          return;
        }

        // ← extend cache guard to also protect peer-left detection
        if (snapshot.metadata.isFromCache) {
          return;
        }

        final data = snapshot.data()!;

        // 1. CAPTURE THE PEER'S LIVE DATABASE STATE DIRECTLY
        final bool isCalleeStillInRoom = data['calleeJoined'] == true;
        final bool endedByPeer = _wasEndedByPeer(data);

        // 2. CHECK IF THEY LEFT *BEFORE* MANIPULATING INTERNAL BOOLEAN GUARDS
        if (_peerJoined && (!isCalleeStillInRoom || endedByPeer)) {
          _notifyPeerLeft();
          return;
        }

        // 3. NOW UPDATE YOUR RESET GUARDS SAFELY
        if (!isCalleeStillInRoom) {
          _offerCreated = false;
          _peerJoined = false;
        }
        // if (data['offer'] == null) {
        //   _offerCreated = false;
        // }
        if (data['offer'] == null || data['answer'] == null) {
          // If callee is present but no complete handshake, allow re-offer
          if (!isCalleeStillInRoom) _offerCreated = false;
        }
        if (data['answer'] == null) {
          _answerHandled = false;
        }

        // if callee is present but _peerJoined was false (rejoined),
        // force reset _offerCreated so fresh offer goes out
        if (!_peerJoined && isCalleeStillInRoom) {
          _offerCreated = false;
        }

        // Trigger offer creation exactly once when callee joins
        if (!_offerCreated && isCalleeStillInRoom) {
          _offerCreated = true;
          _peerJoined = true;
          onUserJoined?.call(roomId);
        }

        // 4. HANDLE ANSWER EXACTLY ONCE
        if (!_answerHandled && data['answer'] != null) {
          _answerHandled = true;
          final answer = Map<String, dynamic>.from(data['answer'] as Map);
          onAnswer?.call(answer, roomId);
        }
      } catch (e) {
        debugPrint('Error in _listenForCallee snapshot: $e');
      }
    });

    // Listen to callee's ICE candidates
    // _candidateSubscription = roomRef.collection(_calleeCandidates).snapshots().listen((snapshot) {
    //   try {
    //     for (final change in snapshot.docChanges) {
    //       if (change.type == DocumentChangeType.added) {
    //         final d = change.doc.data();
    //         if (d != null) onIceCandidate?.call(d);
    //       }
    //     }
    //   } catch (e) {
    //     debugPrint('Error in callee candidates snapshot: $e');
    //   }
    // });
  }

  // Callee listens here: waits for offer + caller ICE candidates
  void _listenForOffer(String roomId) {
    _roomSubscription?.cancel();
    _candidateSubscription?.cancel();

    // ← reset handler guards every time listener is re-attached
    _offerHandled = false;
    _peerJoined = false;
    _isDisconnected = false; // ← add this
    _peerLeftHandled = false; // ← add this

    final roomRef = _firestore.collection(_rooms).doc(roomId);

    _candidateSubscription = roomRef.collection(_callerCandidates).snapshots().listen((snapshot) {
      try {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final d = change.doc.data();
            if (d != null) onIceCandidate?.call(d);
          }
        }
      } catch (e) {
        debugPrint('Error in caller candidates snapshot: $e');
      }
    });

    _roomSubscription = roomRef.snapshots(includeMetadataChanges: true).listen((snapshot) {
      try {
        if (!snapshot.exists) {
          if (_peerJoined) _notifyPeerLeft();
          return;
        }

        // ← extend cache guard to also protect peer-left detection
        if (snapshot.metadata.isFromCache) {
          return;
        }

        final data = snapshot.data()!;

        // 1. CAPTURE THE PEER'S LIVE DATABASE STATE DIRECTLY
        final bool isCallerStillInRoom = data['callerJoined'] == true;
        final bool endedByPeer = _wasEndedByPeer(data);

        // 2. CHECK IF THEY LEFT *BEFORE* MANIPULATING INTERNAL BOOLEAN GUARDS
        if (_peerJoined && (!isCallerStillInRoom || endedByPeer)) {
          _notifyPeerLeft();
          return;
        }

        // 3. NOW UPDATE YOUR RESET GUARDS SAFELY
        if (!isCallerStillInRoom) {
          _peerJoined = false;
        }
        if (data['offer'] == null) {
          _offerHandled = false;
        }

        if (!_offerHandled && data['offer'] != null && data['callerJoined'] == true) {
          _offerHandled = true;
          _peerJoined = true;
          final offer = Map<String, dynamic>.from(data['offer'] as Map);
          onOffer?.call(offer, roomId); // ← pass roomId
        }
      } catch (e) {
        debugPrint('Error in _listenForOffer snapshot: $e');
      }
    });

    // Listen to caller's ICE candidates
    // _candidateSubscription = roomRef.collection(_callerCandidates).snapshots().listen((snapshot) {
    //   try {
    //     for (final change in snapshot.docChanges) {
    //       if (change.type == DocumentChangeType.added) {
    //         final d = change.doc.data();
    //         if (d != null) onIceCandidate?.call(d);
    //       }
    //     }
    //   } catch (e) {
    //     debugPrint('Error in caller candidates snapshot: $e');
    //   }
    // });
  }

  Future<void> sendOffer(String roomId, Map<String, dynamic> offer) async {
    debugPrint('sendOffer → roomId: "$roomId"'); // ← add this
    if (roomId.isEmpty) {
      debugPrint('sendOffer SKIPPED — roomId is empty!');
      return;
    }
    try {
      await _firestore.collection(_rooms).doc(roomId).update({'offer': offer});
      debugPrint('sendOffer SUCCESS');
    } catch (e) {
      debugPrint('sendOffer FAILED: $e');
      onDisconnect?.call('Failed to send offer: $e');
    }
  }

  Future<void> sendAnswer(String roomId, Map<String, dynamic> answer) async {
    debugPrint('sendAnswer → roomId: "$roomId"'); // ← add
    if (roomId.isEmpty) {
      debugPrint('sendAnswer SKIPPED — roomId is empty!');
      return;
    }
    try {
      await _firestore.collection(_rooms).doc(roomId).update({'answer': answer});
      debugPrint('sendAnswer SUCCESS');
    } catch (e) {
      debugPrint('sendAnswer FAILED: $e');
      onDisconnect?.call('Failed to send answer: $e');
    }
  }

  Future<void> sendIceCandidate(String roomId, Map<String, dynamic> candidate) async {
    try {
      // Caller stores in callerCandidates; callee stores in calleeCandidates
      final subcollection = _isCaller ? _callerCandidates : _calleeCandidates;
      await _firestore.collection(_rooms).doc(roomId).collection(subcollection).add({...candidate, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      // Non-fatal — log silently
    }
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    _roomSubscription?.cancel();
    _candidateSubscription?.cancel();

    try {
      final roomRef = _firestore.collection(_rooms).doc(roomId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists) return;
        final data = snapshot.data()!;

        final currentCallerId = data['callerId'] as String?;

        final Map<String, dynamic> updateData = {};

        if (_isCaller && currentCallerId == userId) {
          updateData['callerJoined'] = false;
          updateData['callEnded'] = true;
          updateData['endedBy'] = _roleCaller;
          updateData['endedAt'] = FieldValue.serverTimestamp();
          updateData['offer'] = FieldValue.delete();
          updateData['answer'] = FieldValue.delete();
        } else if (!_isCaller) {
          updateData['calleeJoined'] = false;
          updateData['callEnded'] = true;
          updateData['endedBy'] = _roleCallee;
          updateData['endedAt'] = FieldValue.serverTimestamp();
          updateData['offer'] = FieldValue.delete();
          updateData['answer'] = FieldValue.delete();
        }

        if (updateData.isNotEmpty) {
          transaction.update(roomRef, updateData);
        }
      });

      // Candidate cleanup is housekeeping only — the transaction above already
      // notifies the peer. Run it in the background so the leaver isn't blocked
      // waiting on sequential per-document deletes before exiting the room.
      unawaited(_clearRoomCandidates(roomRef));
    } catch (_) {}
  }

  void disconnect() {
    _isDisconnected = true;
    _roomSubscription?.cancel();
    _candidateSubscription?.cancel();
    _roomSubscription = null;
    _candidateSubscription = null;
    resetForRejoin();
    _isCaller = false;
  }

  void resetForRejoin() {
    _offerCreated = false;
    _answerHandled = false;
    _offerHandled = false;
    _peerJoined = false;
    _peerLeftHandled = false;
  }

  String? _getJoinableRoomError(Map<String, dynamic>? data, String userId) {
    if (data == null) return 'Room ID does not exist.';
    if (userId == data['callerId']) return null; // caller can always rejoin
    if (data['callerJoined'] == true && data['calleeJoined'] == true) {
      return 'This room already has two participants.';
    }
    return null;
  }

  bool _wasEndedByPeer(Map<String, dynamic> data) {
    if (data['callEnded'] != true) return false;
    if (data['callerJoined'] == true && data['calleeJoined'] == true) {
      return false;
    }

    final endedBy = data['endedBy'];
    if (_isCaller) return endedBy != _roleCaller;
    return endedBy != _roleCallee;
  }

  void _notifyPeerLeft() {
    if (_peerLeftHandled || _isDisconnected) return;
    _peerLeftHandled = true;
    onUserLeft?.call();
  }

  Future<void> _clearRoomCandidates(DocumentReference<Map<String, dynamic>> roomRef) async {
    for (final sub in [_callerCandidates, _calleeCandidates]) {
      final docs = await roomRef.collection(sub).get();
      await Future.wait(docs.docs.map((doc) => doc.reference.delete()));
    }
  }
}
