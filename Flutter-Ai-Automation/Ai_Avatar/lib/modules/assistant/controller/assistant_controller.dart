import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:ai_avtar_chat/core/widgets/popup.dart';
import 'package:ai_avtar_chat/modules/assistant/controller/conversation_controller.dart';
import 'package:ai_avtar_chat/modules/assistant/controller/realtime_ws.dart';
import 'package:ai_avtar_chat/modules/assistant/model/assistant_start_response.dart';
import 'package:ai_avtar_chat/services/real_time_conversation.dart';
import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/utils/import_to_export.dart';

/// Coordinates the full AI avatar lifecycle:
/// session start, permission handling, OpenAI realtime, Anam streaming, mic capture, and teardown.
class AssistantController extends GetxController {
  // ───────────────────────────── Constants ─────────────────────────────

  static const String reasonSatisfied = 'statisfied';
  static const String reasonNotSatisfied = 'not statisfied';
  static const String reasonTimeout = 'timeout';
  static const String reasonUserEnded = 'user_ended';

  static const List<String> _satisfiedAIPhrases = [
    "thanks for using Ai Avtar Chat",
    "thank you for using Ai Avtar Chat",
    "thanks for using Ai Avtar Chat and happy gifting",
    "thank you for using Ai Avtar Chat and happy gifting",
    "thanks for using Ai Avtar Chat and please use our gift wizard for more gifts",
  ];

  static const List<String> _notSatisfiedAIPhrases = [
    "if you need more meaningful gifts, try the gift wizard",
    "try the gift wizard",
    "more meaningful gifts, try the gift wizard",
    "please use the wizard if you need more enhance items",
    "please use the wizard if you need more enhanced items",
    "use the Ai Avtar Chat gift wizard for more meaningful gifts",
  ];

  static const List<String> _commonAIClosingPhrases = ["happy gifting"];

  // Keywords the client-side fallback uses to detect an explicit gift request.
  static const List<String> _giftProductKeywords = [
    'watch', 'headphone', 'earphone', 'earbud', 'phone', 'mobile', 'laptop', 'tablet', 'keyboard', 'mouse', 'camera', 'speaker', 'charger', 'gadget', //
    'perfume', 'wallet', 'bag', 'purse', 'shoes', 'sneaker', 'shirt', 'dress', 'toy', 'lego', 'book', 'game', //
    'ring', 'necklace', 'bracelet', 'jewelry', 'chocolate', 'flower', 'candle', 'mug', 'plant', 'hamper', 'voucher', //
    'skincare', 'makeup', 'gym', 'fitness', 'cycle', 'bike',
  ];

  static const Duration _assistantSpeakingTailHold = Duration(milliseconds: 1200);
  // Hard safety net for the mic gate when persona/audio events go silent.
  // Must be long enough to cover the full duration of any AI utterance —
  // including long farewells like "thanks for using Ai Avtar Chat and happy gifting".
  // If shorter than the actual speech, the gate releases mid-sentence, the
  // mic picks up the AI's own voice as echo, OpenAI VAD fires speech_started
  // and interruptPersona() cuts the avatar off.
  static const Duration _assistantSpeakingMaxGate = Duration(seconds: 30);

  // ─────────────────── Observable state (read by UI) ───────────────────

  // Session payload returned by the backend when the assistant starts or refreshes.
  final Rxn<AssistantStartResponse> sessionData = Rxn<AssistantStartResponse>();
  // High-level connection flags that the UI uses to show loading or ready states.
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString currentSessionId = "".obs;

  // UI toggles for microphone and optional noise cancellation.
  final isMicEnabled = true.obs;
  final isNoiseCancellationEnabled = true.obs;
  final isAnamConnected = false.obs;
  final isAnamStreamReady = false.obs;
  final isClosingSession = false.obs;
  final RxBool isOverlayVisible = false.obs;

  // Full conversation so far, persisted to the backend as the session context.
  final RxList<Map<String, String>> conversationTranscript = <Map<String, String>>[].obs;

  // WebRTC renderer the UI binds to for the avatar video. Recreated per session.
  RTCVideoRenderer renderer = RTCVideoRenderer();
  OverlayEntry? overlayEntry;

  // ───────────────────────── Internal state ─────────────────────────

  // Realtime WebSocket client that talks to OpenAI's realtime API.
  RealtimeWS? _client;
  // Timer used to refresh the ephemeral session token before it expires.
  Timer? _refreshTimer;
  // Completer used to wait until the avatar stream is actually ready before starting mic capture.
  Completer<void>? _anamReadyCompleter;

  // Native microphone recorder that streams PCM chunks into the OpenAI socket.
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSub;
  bool _isRecording = false;

  // Anam avatar client used to render and control the animated persona.
  AnamClient? _anamClient;
  final List<StreamSubscription> _anamSubscriptions = [];
  bool _isAnamInitializing = false;

  // Keeps the latest transcript per item id so the backend can persist the full session context.
  final Map<String, Map<String, String>> _transcriptMap = {};

  String? _pendingEndReason;
  bool _isAssistantSpeaking = false;
  Timer? _assistantSpeakingHoldTimer;
  Timer? _assistantSpeakingWatchdog;

  // Tracks exact duration of AI speech to prevent mic echo.
  int _aiAudioBytesReceived = 0;
  DateTime? _aiSpeechStartTime;

  bool _isClosing = false;

  Offset _screenOffset = Offset.zero;

  @override
  void onClose() {
    disposeSession();
    super.onClose();
  }

  // ───────────────────────── Session start ─────────────────────────

  /// Starts an assistant session.
  /// Set [showOverlay] to false when the calling screen renders the avatar inline
  /// (e.g. AvatarChatScreen) — skips the draggable floating-card overlay entirely.
  Future<void> startAssistant(BuildContext context, {bool showOverlay = true}) async {
    await WakelockPlus.enable();
    if (isConnected.value || isConnecting.value || isOverlayVisible.value) {
      return;
    }

    isConnecting.value = true;
    final startTs = DateTime.now();
    try {
      // Ask for microphone permission before creating any backend session.
      if (!await _ensureMicPermission()) {
        isConnecting.value = false;
        return;
      }

      // Start the backend assistant session first so we receive the ephemeral token and avatar config.
      final response = await RealTimeConversationServices.startSession();
      if (response.status != true || response.data == null) {
        Get.snackbar("Error", "Failed to start assistant session");
        isConnecting.value = false;
        return;
      }

      sessionData.value = response;
      currentSessionId.value = response.data!.sessionId!;
      _setupRefreshTimer(response.data!.expiresAt!);

      // Only insert the floating overlay when the caller wants it.
      // Inline screens (AvatarChatScreen) render the video themselves.
      // Use Get.context! here — the original context may be stale after the awaits above.
      if (showOverlay) showOverlayEntry(Get.context!);

      _anamReadyCompleter = Completer<void>();

      await Future.wait([_initAnam(response.data!), _connectAndConfigureOpenAI(response.data!)]);

      // Wait until both the WebRTC connection and the avatar stream are ready before opening the mic.
      await _waitForAnamReady();

      // Start capturing microphone audio only after the full audio chain is stable.
      await _startMicStream();

      isConnected.value = true;
      log("[Session] isConnected set to true - mic now allowed to flow");

      log("[Session] Ready in ${DateTime.now().difference(startTs).inMilliseconds}ms");
    } catch (e) {
      log("Error starting assistant: $e");
      // Tear down any partial state so a stuck overlay/loader doesn't remain
      // and the next start attempt begins from a clean slate.
      try {
        await disposeSession();
      } catch (cleanupErr) {
        log("Error during failed-start cleanup: $cleanupErr");
      }
      Get.snackbar("Error", "An unexpected error occurred. Please try again.");
    } finally {
      isConnecting.value = false;
    }
  }

  /// Requests microphone permission, guiding the user to settings when it is
  /// permanently denied. Returns true only when recording is allowed.
  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      Get.dialog(
        AlertCustomDialog(
          text: "Microphone access is permanently denied. Please enable it in app settings to use the assistant.",
          ontap: () {
            Get.back();
            openAppSettings();
          },
          btntext: "Settings",
          isDisplayedCancelBtn: true,
        ),
      );
      return false;
    }

    final requested = await Permission.microphone.request();
    if (!requested.isGranted) {
      log("[Mic] Permission denied");
      Get.dialog(AlertCustomDialog(text: "Microphone access is required for the AI assistant.", ontap: () => Get.back(), btntext: "OK", isDisplayedCancelBtn: false));
      return false;
    }
    return true;
  }

  Future<void> _waitForAnamReady() async {
    // Wait until BOTH the WebRTC peer connection has been established
    // AND the remote video/audio stream has been received & attached.
    // The previous version only awaited connectionEstablished, which can
    // fire BEFORE onStreamReady — leaving Helper.setSpeakerphoneOn() and
    // the iOS AVAudioSession in a transitional state when the mic starts.
    if (isAnamConnected.value && isAnamStreamReady.value) {
      log("[Session] Anam already ready (connected + stream)");
      return;
    }
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (DateTime.now().isBefore(deadline)) {
      if (isAnamConnected.value && isAnamStreamReady.value) {
        log("[Session] Anam ready (connected + stream)");
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    log("[Session] Error: Anam ready timed out. connected=${isAnamConnected.value}, streamReady=${isAnamStreamReady.value}");
    throw TimeoutException("AI Avatar connection timed out. Please try again.");
  }

  // ───────────────────────── Token refresh ─────────────────────────

  void _setupRefreshTimer(int expiresAt) {
    _refreshTimer?.cancel();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final delay = expiresAt - now - 60;
    if (delay > 0) {
      _refreshTimer = Timer(Duration(seconds: delay), _handleTokenRefresh);
    }
  }

  Future<void> _handleTokenRefresh() async {
    if (currentSessionId.value.isEmpty) return;
    try {
      final response = await RealTimeConversationServices.refreshToken(currentSessionId.value);
      if (response.status == true && response.data != null) {
        sessionData.value = response;
        _setupRefreshTimer(response.data!.expiresAt!);
        await _reconnectOpenAI(response.data!);
      }
    } catch (e) {
      log("Error refreshing token: $e");
    }
  }

  // ──────────────────── OpenAI realtime connection ────────────────────

  // Builds the realtime client, registers tool callbacks, and optionally replays any prior context messages.
  Future<void> _connectAndConfigureOpenAI(Data data) async {
    final connected = await _openRealtimeConnection(
      ephemeralToken: data.ephemeralToken ?? "",
      toolsData: data,
      model: data.model,
      instructions: data.systemPrompt,
      voice: data.voice,
    );
    if (!connected) {
      log("[OpenAI] Connect failed — check ephemeral token (TTL 600s), model, or network");
      return;
    }
    log("[OpenAI] Connected");

    if (data.contextMessages != null && data.contextMessages!.isNotEmpty) {
      log("[OpenAI] Replaying ${data.contextMessages!.length} context messages from backend");
      for (var msg in data.contextMessages!) {
        _sendConversationMessage(role: _normalizeRole(msg.role), text: msg.content ?? "");
      }
    }
  }

  /// Reconnects with a fresh ephemeral token (after a refresh) and replays the
  /// local transcript so the new connection keeps the conversation context.
  Future<void> _reconnectOpenAI(Data data) async {
    await _stopMicStream();

    await _client?.disconnect();
    _client = null;

    final savedData = sessionData.value?.data;
    final connected = await _openRealtimeConnection(
      ephemeralToken: data.ephemeralToken ?? "",
      toolsData: savedData ?? data,
      model: data.model,
      instructions: _withLanguageInstruction(data.systemPrompt ?? savedData?.systemPrompt),
      voice: data.voice ?? savedData?.voice,
    );
    if (!connected) return;

    for (var msg in conversationTranscript) {
      _sendConversationMessage(role: _normalizeRole(msg['role']), text: msg['content'] ?? "");
    }

    await _startMicStream();
  }

  /// Creates the realtime client, registers event handlers and tools, and opens
  /// the WebSocket. Returns false (and clears the client) when the connect fails.
  Future<bool> _openRealtimeConnection({required String ephemeralToken, required Data toolsData, String? model, String? instructions, String? voice}) async {
    if (ephemeralToken.isEmpty) {
      log("[OpenAI] Warning: Ephemeral token is empty");
    }
    _client = RealtimeWS(apiKey: ephemeralToken, debug: true);
    _registerEventHandlers();
    _registerTools(toolsData);
    log("[OpenAI] Tools registered");

    final connected = await _client?.connect(model: model ?? "gpt-realtime", instructions: instructions, voice: voice) ?? false;
    if (!connected) _client = null;
    return connected;
  }

  void _registerEventHandlers() {
    final client = _client;
    if (client == null) return;
    log("[OpenAI] Registering event handlers");

    client.onError = (err) {
      log("[OpenAI] Error event: $err");
    };

    client.onSpeechStarted = () {
      // Suppress any interrupt while a farewell is queued OR the close is in
      // progress. The avatar's own audio playing through the speaker can leak
      // back into the mic and trigger server VAD; without this guard, phrases
      // like "thanks for using Ai Avtar Chat and happy gifting" get cut off and a
      // brand-new response can be generated after the goodbye.
      if (_isClosing || _pendingEndReason != null) {
        log("[OpenAI] speech_started suppressed (closing=$_isClosing, pendingEnd=${_pendingEndReason != null})");
        return;
      }
      if (_anamClient?.isDataChannelOpen == true) {
        try {
          _anamClient?.interruptPersona();
          _anamClient?.endAgentAudioSequence();
        } catch (e) {
          log("[Anam] interrupt failed: $e");
        }
      }

      // Reset AI speech tracking so we don't hold the mic closed based on old audio length
      _aiAudioBytesReceived = 0;
      _aiSpeechStartTime = DateTime.now();

      log("[OpenAI] speech started — interrupting");
    };

    client.onAudioDelta = (bytes) {
      _aiAudioBytesReceived += bytes.length;
      _markAssistantSpeaking("AI audio streaming");
      _onAudioDelta(bytes);
    };

    client.onAudioDone = () {
      if (isAnamConnected.value) {
        _anamClient?.endAgentAudioSequence();
      }

      // Calculate exact duration of the audio we just received to gate the mic perfectly.
      // 24000 Hz, 1 channel, 16-bit (2 bytes per sample) = 48000 bytes per second.
      final double audioDurationSeconds = _aiAudioBytesReceived / 48000.0;
      final elapsed = DateTime.now().difference(_aiSpeechStartTime ?? DateTime.now());
      final int remainingMs = (audioDurationSeconds * 1000).toInt() - elapsed.inMilliseconds;

      // Add 1.5 seconds padding for network and Anam processing delay
      final int holdTimeMs = (remainingMs > 0 ? remainingMs : 0) + 1500;
      log("[Mic] Audio done. Audio: ${audioDurationSeconds.toStringAsFixed(2)}s, Elapsed: ${elapsed.inMilliseconds}ms. Gating for additional $holdTimeMs ms.");

      _scheduleAssistantSpeakingRelease(holdTimeMs);
    };

    client.onResponseDone = () {
      if (isAnamConnected.value) {
        _anamClient?.endAgentAudioSequence();
      }
      final reason = _pendingEndReason;
      if (reason != null) {
        _pendingEndReason = null;
        log("[OpenAI] AI farewell delivered — closing session ($reason)");
        if (isConnected.value) finalizeAndClose(reason);
      }
    };

    client.onTranscriptUpdated = (role, text, itemId, isFinal) {
      if (text.isEmpty) return;
      // Build/update the map entry for this turn (deltas accumulate until isFinal).
      _transcriptMap[itemId] = {"role": role, "content": text};
      if (isFinal) {
        conversationTranscript.assignAll(_transcriptMap.values.toList());
        if (role == 'assistant') {
          _checkForAIGoodbye(text);
        }
        // Fallback: if the user explicitly names a gift and AI hasn't searched yet,
        // trigger the search from the client side without waiting for the tool call.
        if (role == 'user') {
          _clientSideGiftSearchFallback(text);
        }
        // _saveCurrentTranscript();
      }
    };
  }

  /// Prepends a language-enforcement rule (English by default, switch only on
  /// explicit user request) to the backend system prompt. Injected client-side
  /// so it survives backend prompt changes; currently applied on reconnect only.
  String _withLanguageInstruction(String? basePrompt) {
    const rule =
        'LANGUAGE RULE: Always respond in English by default. '
        'Only switch to a different language if the user EXPLICITLY requests it '
        '(e.g. "please speak Hindi" or "respond in French"). '
        'Remember the user\'s chosen language for the rest of the session once '
        'they ask for a switch. Never switch language on your own initiative.\n\n';
    return rule + (basePrompt ?? '');
  }

  String _normalizeRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'assistant':
        return 'assistant';
      case 'system':
        return 'system';
      default:
        return 'user';
    }
  }

  void _sendConversationMessage({required String role, required String text}) {
    final client = _client;
    final value = text.trim();
    if (client == null || value.isEmpty) return;

    if (role == 'assistant') {
      client.sendAssistantMessage(value);
    } else if (role == 'system') {
      client.sendSystemMessage(value);
    } else {
      client.sendUserMessage(value);
    }
  }

  // ───────────────────────────── Tools ─────────────────────────────

  /// Tool definitions used when the backend omits a tool from its list, so the
  /// UI never silently breaks when the server config changes.
  static const Map<String, Map<String, dynamic>> _fallbackToolDefinitions = {
    'search_gifts': {
      'name': 'search_gifts',
      'description': 'Search for gift products based on the user\'s request. Call this whenever the user mentions a type of gift or names a recipient.',
      'parameters': {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Natural-language gift search query, e.g. "smartwatch for a 25-year-old tech-loving brother"'},
        },
        'required': ['query'],
      },
    },
    'end_conversation': {
      'name': 'end_conversation',
      'description': 'End the gift-suggestion session.',
      'parameters': {
        'type': 'object',
        'properties': {
          'reason': {'type': 'string', 'description': 'satisfied | not_satisfied | timeout'},
        },
        'required': ['reason'],
      },
    },
  };

  /// Registers all tools provided by the backend, then registers a hardcoded
  /// fallback for any supported tool the backend left out.
  void _registerTools(Data data) {
    final client = _client;
    if (client == null) return;

    final callbacks = <String, RealtimeToolCallback>{'search_gifts': _searchGiftsCallback, 'end_conversation': _endConversationCallback};

    // Track which tools were configured by the backend.
    final backendToolNames = <String>{};
    for (final tool in data.tools ?? <Tool>[]) {
      backendToolNames.add(tool.name ?? '');
      final callback = callbacks[tool.name];
      if (callback != null) {
        client.registerTool({'name': tool.name, 'description': tool.description, 'parameters': tool.parameters}, callback);
      }
    }

    for (final entry in _fallbackToolDefinitions.entries) {
      if (backendToolNames.contains(entry.key)) continue;
      log("[Tools] Backend did not include ${entry.key} — registering fallback");
      client.registerTool(entry.value, callbacks[entry.key]!);
    }
  }

  /// Shared callback for the `search_gifts` tool — used by both the backend
  /// tool registration and the hardcoded fallback.
  Future<Map<String, dynamic>> _searchGiftsCallback(Map<String, dynamic> params) async {
    final query = (params['query'] ?? '').toString().trim();
    if (query.isEmpty) return {'success': false, 'error': 'Empty query'};

    log("[Tool] search_gifts called with query: $query");
    try {
      final conv = Get.find<ConversationController>();
      conv.isFetching.value = false;
      conv.isDialogOpenAlready.value = false;
      conv.page.value = 1;
      await conv.searchKeyWord(query);
      return {'success': true, 'query': query};
    } catch (e) {
      log("[Tool] search_gifts failed: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Shared callback for the `end_conversation` tool.
  Future<Map<String, dynamic>> _endConversationCallback(Map<String, dynamic> params) async {
    final reason = (params['reason'] ?? reasonSatisfied).toString();

    _pendingEndReason = reason;
    return {'success': true};
  }

  /// Triggered after every finalised user transcript: if the user directly
  /// names a product and the AI has not yet shown any gift cards, fire the
  /// search without waiting for the AI's tool call.
  void _clientSideGiftSearchFallback(String userText) {
    final conv = Get.find<ConversationController>();
    // Skip if results are already showing or a fetch is in progress.
    if (conv.giftProducts.isNotEmpty || conv.isFetching.value) return;
    // Wait until Ava has spoken at least once (intro is done).
    final hasAiSpoken = conversationTranscript.any((m) => m['role'] == 'assistant');
    if (!hasAiSpoken) return;

    final q = userText.toLowerCase();
    final matched = _giftProductKeywords.any((k) => q.contains(k));
    if (!matched) return;

    log("[Search] Client-side fallback triggered for: $userText");
    conv.isFetching.value = false;
    conv.page.value = 1;
    conv.searchKeyWord(userText);
  }

  // ───────────────── Microphone capture & echo gating ─────────────────

  Future<void> _startMicStream() async {
    if (_isRecording) return;

    try {
      final stream = await _audioRecorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 24000,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: isNoiseCancellationEnabled.value,
          autoGain: isNoiseCancellationEnabled.value,
          // ignore: deprecated_member_use
          iosConfig: const IosRecordConfig(manageAudioSession: false),
        ),
      );

      _isRecording = true;

      int chunkCount = 0;
      _micSub = stream.listen(
        (Uint8List chunk) {
          if (!isMicEnabled.value) return;

          if (_isClosing) return;

          // Gated — AI is speaking; forwarding would echo its voice back.
          if (_isAssistantSpeaking) return;

          if (_client == null || !isConnected.value) {
            return;
          }

          chunkCount++;
          if (chunkCount == 1 || chunkCount % 200 == 0) {
            log("[Mic] Sent chunk #$chunkCount (${chunk.length} bytes)");
          }
          _client?.appendInputAudio(chunk);
        },
        onError: (e) => log("[Mic] Stream error: $e"),
        onDone: () {
          _isRecording = false;
          log("[Mic] Stream closed after $chunkCount chunks");
        },
        cancelOnError: false,
      );

      log("[Mic] PCM16 stream started at 24 kHz (manageAudioSession=false)");
    } catch (e) {
      log("[Mic] Failed to start stream: $e");
    }
  }

  Future<void> _stopMicStream() async {
    await _micSub?.cancel();
    _micSub = null;
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;
    }
    log("[Mic] Stream stopped");
  }

  /// Toggles the microphone on/off. Public so the chat screen can wire it to a button.
  void toggleMic() {
    isMicEnabled.value = !isMicEnabled.value;
    log("[Mic] ${isMicEnabled.value ? 'Unmuted' : 'Muted'}");
  }

  void _markAssistantSpeaking(String reason) {
    if (!_isAssistantSpeaking) {
      _isAssistantSpeaking = true;
      _aiSpeechStartTime = DateTime.now();
      _aiAudioBytesReceived = 0;
      log("[Mic] Gated — $reason");
    }
    _assistantSpeakingHoldTimer?.cancel();
    _assistantSpeakingWatchdog?.cancel();
    _assistantSpeakingWatchdog = Timer(_assistantSpeakingMaxGate, () {
      if (_isAssistantSpeaking) {
        _isAssistantSpeaking = false;
        _assistantSpeakingHoldTimer?.cancel();
        log("[Mic] Watchdog: forcibly re-opened after ${_assistantSpeakingMaxGate.inSeconds}s without release event");
      }
    });
  }

  void _scheduleAssistantSpeakingRelease([int? delayMs]) {
    _assistantSpeakingHoldTimer?.cancel();
    final delay = delayMs != null ? Duration(milliseconds: delayMs) : _assistantSpeakingTailHold;
    _assistantSpeakingHoldTimer = Timer(delay, () {
      _isAssistantSpeaking = false;
      _aiSpeechStartTime = null;
      _aiAudioBytesReceived = 0;
      _assistantSpeakingWatchdog?.cancel();
      _client?.clearInputAudio(); // Clear the server buffer to discard any echo picked up during the hold period
      log("[Mic] Re-opened after AI speech tail hold - Buffer cleared");
    });
  }

  // ───────────────────────── Anam avatar ─────────────────────────

  Future<void> _initAnam(Data data) async {
    if (_isAnamInitializing) {
      log("[Anam] Already initializing, skipping");
      return;
    }

    final sessionToken = data.anamSessionToken;
    if (sessionToken == null || sessionToken.isEmpty) {
      log("[Anam] No session token — skipping");
      return;
    }

    _isAnamInitializing = true;
    try {
      await _attemptAnamConnection(sessionToken: sessionToken, personaId: data.avatarId ?? "", avatarId: data.avatarId ?? "", voiceId: data.voice ?? "");
    } finally {
      _isAnamInitializing = false;
    }
  }

  Future<void> _attemptAnamConnection({required String sessionToken, required String personaId, required String avatarId, required String voiceId}) async {
    try {
      log("[Anam] Initialising renderer");
      try {
        renderer.dispose();
      } catch (_) {}
      renderer = RTCVideoRenderer();
      await renderer.initialize();

      _anamClient = AnamClientFactory.createClient(sessionToken: sessionToken, enableLogging: false, disableClientAudio: true);

      _registerAnamEventListeners();
      _anamClient?.setInputAudioEnabled(false);

      await _anamClient?.talk(
        personaConfig: PersonaConfig(personaId: personaId, name: 'AI Assistant', avatarId: avatarId, voiceId: voiceId, maxSessionLengthSeconds: 600),
        onStreamReady: (stream) async {
          if (stream != null) {
            await Helper.setSpeakerphoneOn(true);
            for (var track in stream.getAudioTracks()) {
              track.enabled = true;
            }

            renderer.srcObject = stream;
            isAnamStreamReady.value = true;
            overlayEntry?.markNeedsBuild();
          }
        },
      );

      log("[Anam] talk() initiated");
    } catch (e) {
      log("[Anam] Connection failed: $e");
    }
  }

  void _registerAnamEventListeners() {
    if (_anamClient == null) return;

    for (final sub in _anamSubscriptions) {
      sub.cancel();
    }
    _anamSubscriptions.clear();

    _anamSubscriptions.add(
      _anamClient!.on(AnamEvent.connectionEstablished).listen((_) {
        isAnamConnected.value = true;
        log("[Anam] Connected");
        if (_anamReadyCompleter != null && !_anamReadyCompleter!.isCompleted) {
          _anamReadyCompleter!.complete();
        }
      }),
    );

    _anamSubscriptions.add(
      _anamClient!.on(AnamEvent.connectionClosed).listen((_) {
        isAnamConnected.value = false;
        log("[Anam] Connection closed");
      }),
    );

    _anamSubscriptions.add(
      _anamClient!.on(AnamEvent.error).listen((error) {
        log("[Anam] Error: $error");
      }),
    );

    _anamSubscriptions.add(
      _anamClient!.on(AnamEvent.personaTalking).listen((_) {
        _markAssistantSpeaking("Persona is talking");
      }),
    );

    _anamSubscriptions.add(
      _anamClient!.on(AnamEvent.personaListening).listen((_) {
        _scheduleAssistantSpeakingRelease();
      }),
    );
  }

  void _onAudioDelta(Uint8List bytes) {
    if (!isAnamConnected.value) {
      return;
    }
    _anamClient?.appendInputAudio(bytes);
  }

  // ───────────────── Transcript & farewell detection ─────────────────

  void _checkForAIGoodbye(String text) {
    if (_pendingEndReason != null) return;
    final lower = text.toLowerCase();

    if (_matchFarewell(lower, _satisfiedAIPhrases, "Satisfied farewell", reasonSatisfied)) return;
    if (_matchFarewell(lower, _notSatisfiedAIPhrases, "Not-satisfied farewell", reasonNotSatisfied)) return;
    _matchFarewell(lower, _commonAIClosingPhrases, "Common closing (defaulting to satisfied)", reasonSatisfied);
  }

  /// Sets [_pendingEndReason] to [reason] when [lower] contains any of [phrases].
  bool _matchFarewell(String lower, List<String> phrases, String label, String reason) {
    for (final phrase in phrases) {
      if (lower.contains(phrase.toLowerCase())) {
        log("[OpenAI] $label matched: '$phrase'");
        _pendingEndReason = reason;
        return true;
      }
    }
    return false;
  }

  // Future<void> _saveCurrentTranscript() async {
  //   if (currentSessionId.value.isEmpty || conversationTranscript.isEmpty) {
  //     return;
  //   }
  //   await RealTimeConversationServices.saveContext(currentSessionId.value, conversationTranscript);
  // }

  // ───────────────────────── Session teardown ─────────────────────────

  Future<void> finalizeAndClose(String reason) async {
    if (!isConnected.value && !isConnecting.value) return;
    if (_isClosing) {
      log("[Session] finalizeAndClose re-entry ignored");
      return;
    }
    _isClosing = true;
    isClosingSession.value = true;
    log("[Session] Finalizing session: $reason");

    // Immediately stop the mic from forwarding audio to OpenAI. Done BEFORE
    // the farewell wait so the AI's own voice cannot leak back through the
    // mic and trigger a new response or interrupt the closing utterance.
    isConnected.value = false;
    isConnecting.value = false;

    // For AI-driven endings (satisfied / not satisfied / timeout), wait until
    // the avatar has actually finished speaking the farewell before tearing
    // down the overlay. We listen for Anam's personaListening event with a
    // safety timeout so the session can never hang.
    if (reason != reasonUserEnded) {
      await _waitForAvatarFinishSpeaking();
    }

    // Capture session info before disposeSession clears it.
    final sessionId = currentSessionId.value;
    final transcript = List<Map<String, String>>.from(conversationTranscript);

    // Signal Anam we're done (only after the farewell finished).
    try {
      _anamClient?.endAgentAudioSequence();
    } catch (e) {
      log("[Session] Error ending Anam audio sequence: $e");
    }

    // Hide overlay and tear down all WebRTC / WS / mic resources. Awaiting
    // disposeSession is critical so the next session starts on clean state.
    await disposeSession();

    // Notify backend the session is done.
    if (sessionId.isNotEmpty) {
      try {
        await RealTimeConversationServices.finalizeSession(sessionId, reason: reason, messages: transcript).timeout(const Duration(seconds: 3));
        Settings.lastChatBotTime = DateTime.now().millisecondsSinceEpoch;
      } catch (e) {
        log("[Session] Finalize API error: $e");
      }
    }
  }

  /// Resolves when Anam emits personaListening (persona has stopped speaking),
  /// with a hard timeout so the overlay can never linger if events misfire.
  /// A short tail buffer lets the last audio frames flush through the speakers.
  Future<void> _waitForAvatarFinishSpeaking({Duration maxWait = const Duration(seconds: 8), Duration tailBuffer = const Duration(milliseconds: 800)}) async {
    final anam = _anamClient;
    if (anam == null || !isAnamConnected.value) {
      log("[Session] No active Anam — skipping farewell wait");
      await Future.delayed(tailBuffer);
      return;
    }

    log("[Session] Waiting for avatar to finish farewell (max ${maxWait.inSeconds}s)...");
    final completer = Completer<void>();
    final listeningSub = anam.on(AnamEvent.personaListening).listen((_) {
      if (!completer.isCompleted) {
        log("[Session] Farewell wait done: personaListening received");
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(maxWait);
    } on TimeoutException {
      log("[Session] Farewell wait hard-timeout at ${maxWait.inSeconds}s");
    } finally {
      await listeningSub.cancel();
    }

    await Future.delayed(tailBuffer);
  }

  /// Releases all runtime resources and resets the controller to a clean idle state.
  Future<void> disposeSession() async {
    // Hide the avatar overlay first so the widget tree detaches before the renderer is disposed.
    isAnamStreamReady.value = false;
    removeOverlayEntry();

    // Stop mic stream so no more chunks are sent during teardown.
    await _stopMicStream();

    // Cancel timers.
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _assistantSpeakingHoldTimer?.cancel();
    _assistantSpeakingHoldTimer = null;
    _assistantSpeakingWatchdog?.cancel();
    _assistantSpeakingWatchdog = null;

    // Cancel Anam event subscriptions BEFORE stopping streaming, so
    // connectionClosed events from the dying client don't mutate state.
    for (final sub in _anamSubscriptions) {
      await sub.cancel();
    }
    _anamSubscriptions.clear();

    // Tear down OpenAI WS and Anam WebRTC fully — must be awaited so the
    // next session can create fresh peer connections without conflict.
    try {
      await _client?.disconnect();
    } catch (e) {
      log("[Session] Error disconnecting OpenAI WS: $e");
    }
    _client = null;

    try {
      await _anamClient?.stopStreaming();
    } catch (e) {
      log("[Session] Error stopping Anam: $e");
    }
    _anamClient = null;

    // Dispose renderer (after Anam streams are stopped and overlay gone).
    try {
      await renderer.dispose();
    } catch (_) {}

    await WakelockPlus.disable();

    isConnected.value = false;
    isAnamConnected.value = false;
    isMicEnabled.value = true;
    isNoiseCancellationEnabled.value = true;
    _isAnamInitializing = false;
    _pendingEndReason = null;
    _isAssistantSpeaking = false;
    _anamReadyCompleter = null;
    _isClosing = false;
    isClosingSession.value = false;
    currentSessionId.value = "";
    conversationTranscript.clear();
    _transcriptMap.clear();
    _screenOffset = Offset.zero;

    log("[Session] Disposed cleanly");
  }

  // ───────────────────── Floating overlay UI ─────────────────────

  void showOverlayEntry(BuildContext context) {
    overlayEntry = OverlayEntry(builder: (ctx) => _buildOverlayContent(ctx));
    isOverlayVisible.value = true;
    Overlay.of(context).insert(overlayEntry!);
  }

  void removeOverlayEntry() {
    try {
      if (overlayEntry != null && overlayEntry!.mounted) {
        overlayEntry!.remove();
      }
    } catch (e) {
      log("Error removing overlay: $e");
    }
    overlayEntry = null;
    isOverlayVisible.value = false;
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(ignoring: true, child: Container(color: Colors.transparent)),
        _buildDraggableWidget(),
      ],
    );
  }

  Widget _buildDraggableWidget() {
    return Positioned(
      bottom: _screenOffset.dy,
      right: _screenOffset.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          _screenOffset = Offset(_screenOffset.dx - details.delta.dx, _screenOffset.dy - details.delta.dy);
          overlayEntry!.markNeedsBuild();
        },
        child: Material(color: Colors.transparent, child: _buildFloatingCard()),
      ),
    );
  }

  Widget _buildFloatingCard() {
    return Container(
      height: 160,
      width: 200,
      decoration: BoxDecoration(color: const Color(0xffE7F4FD), borderRadius: BorderRadius.circular(8)),
      child: Stack(children: [_buildAvatarVideo(), _buildControls()]),
    );
  }

  Widget _buildAvatarVideo() {
    return Obx(() {
      if (!isAnamStreamReady.value) {
        return SizedBox(
          height: 180,
          width: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/loaderlogo.gif", height: 60),
                const SizedBox(height: 8),
                const Text("Connecting...", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ).paddingOnly(bottom: 25),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ClipRect(
          child: Transform.scale(
            scale: 1.25,
            alignment: Alignment.center,
            child: AnamAvatarView(renderer: renderer, isMicEnabled: true, showControls: false, borderRadius: 12.0, backgroundColor: Colors.black),
          ),
        ),
      );
    });
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildEndCallButton(), _buildMicButton()]),
        10.heightBox,
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Image.asset('assets/images/call_end.png', height: 35, width: 35).onTap(() => finalizeAndClose(reasonUserEnded));
  }

  Widget _buildMicButton() {
    return Obx(() => Image.asset(isMicEnabled.value ? 'assets/images/mic_unmute.png' : 'assets/images/mic_mute.png', height: 35, width: 35).onTap(toggleMic));
  }
}
