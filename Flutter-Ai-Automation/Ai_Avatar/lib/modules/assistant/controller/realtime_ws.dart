import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Signature for a function that handles a registered tool call and returns
/// the JSON-serialisable result map.
typedef RealtimeToolCallback = Future<Map<String, dynamic>> Function(Map<String, dynamic> args);

class RealtimeWS {
  RealtimeWS({required this.apiKey, this.url = 'wss://api.openai.com/v1/realtime', this.debug = false});

  final String url;
  final String apiKey;

  /// When true, non-audio events are logged to the developer console.
  final bool debug;

  WebSocketChannel? _ws;
  StreamSubscription? _sub;
  bool _isConnected = false;

  /// True while the server has an active response in flight — used to
  /// guard against duplicate createResponse() calls.
  bool _isResponseActive = false;
  String? _activeResponseId;

  // Tool definitions sent to the server via session.update.
  final List<Map<String, dynamic>> _toolDefs = [];
  // Client-side handler callbacks keyed by tool name.
  final Map<String, RealtimeToolCallback> _toolCallbacks = {};

  String _model = '';
  String? _instructions;
  String _voice = 'alloy';
  String? _transcriptionModel = 'whisper-1';

  // ── Public callbacks ─────────────────────────────────────────────────────────

  /// Called for every audio chunk emitted by the model.
  void Function(Uint8List bytes)? onAudioDelta;

  /// Called once when the current audio response output stream is complete.
  void Function()? onAudioDone;

  /// Called when server VAD detects the user has started speaking.
  void Function()? onSpeechStarted;

  /// Called for both delta (streaming) and final (complete) transcript events.
  /// [isFinal] is false for streaming deltas, true when the full text arrives.
  void Function(String role, String text, String itemId, bool isFinal)? onTranscriptUpdated;

  /// Called when the server emits an error event.
  void Function(String error)? onError;

  /// Called when the model's full response turn is complete.
  void Function()? onResponseDone;

  bool get isConnected => _isConnected;

  // ── Tool registration ────────────────────────────────────────────────────────

  /// Registers a tool by its JSON-schema definition and a local callback.
  /// If [_isConnected] is already true the session is updated immediately
  /// so the model knows about the new tool.
  void registerTool(Map<String, dynamic> def, RealtimeToolCallback callback) {
    final name = def['name'] as String?;
    if (name == null) return;
    // Replace any existing registration with the same name.
    _toolDefs.removeWhere((t) => t['name'] == name);
    _toolDefs.add({
      'type': 'function',
      'name': name,
      if (def['description'] != null) 'description': def['description'],
      if (def['parameters'] != null) 'parameters': def['parameters'],
    });
    _toolCallbacks[name] = callback;
    if (_isConnected) sendSessionUpdate();
  }

  // ── Connection lifecycle ─────────────────────────────────────────────────────

  /// Opens the WebSocket, waits for the connection to be ready, then sends the
  /// initial session.update so the server knows the audio format and tools.
  Future<bool> connect({required String model, String? instructions, String? voice, String? transcriptionModel}) async {
    if (_isConnected) return true;
    _model = model;
    _instructions = instructions;
    if (voice != null && voice.isNotEmpty) _voice = voice;
    if (transcriptionModel != null) _transcriptionModel = transcriptionModel;

    final uri = Uri.parse('$url?model=${Uri.encodeComponent(model)}');
    try {
      _ws = IOWebSocketChannel.connect(uri, protocols: const ['realtime'], headers: {'Authorization': 'Bearer $apiKey'});
      await _ws!.ready;
      _isConnected = true;
      _sub = _ws!.stream.listen(
        _handleMessage,
        onError: (e) {
          log('[RealtimeWS] stream error: $e');
          onError?.call(e.toString());
        },
        onDone: () {
          log('[RealtimeWS] stream closed');
          _isConnected = false;
        },
        cancelOnError: false,
      );
      sendSessionUpdate();
      return true;
    } catch (e) {
      log('[RealtimeWS] connect failed: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Sends (or re-sends) the session configuration.  Call this after adding
  /// new tools while already connected.
  void sendSessionUpdate({String? instructions, String? voice}) {
    if (instructions != null) _instructions = instructions;
    if (voice != null && voice.isNotEmpty) _voice = voice;
    _send({
      'type': 'session.update',
      'session': {
        'type': 'realtime',
        'model': _model,
        if (_instructions != null) 'instructions': _instructions,
        'tools': _toolDefs,
        'tool_choice': _toolDefs.isEmpty ? 'none' : 'auto',
        'audio': {
          'input': {
            'format': {'type': 'audio/pcm', 'rate': 24000},
            // Server-side VAD with 500 ms silence timeout before it commits a turn.
            'turn_detection': {
              'type': 'server_vad',
              'threshold': 0.8, // Increased to reduce false VAD triggers from background noise
              'prefix_padding_ms': 300,
              'silence_duration_ms': 1000, // Increased to allow natural pauses
            },
            // Multilingual transcription (auto-detects language)
            if (_transcriptionModel != null) 'transcription': {'model': _transcriptionModel},
          },
          'output': {
            'format': {'type': 'audio/pcm', 'rate': 24000},
            'voice': _voice,
          },
        },
      },
    });
  }

  // ── Audio I/O ────────────────────────────────────────────────────────────────

  /// Appends a raw PCM16 chunk to the server's input audio buffer.
  void appendInputAudio(Uint8List bytes) {
    if (bytes.isEmpty) return;
    _send({'type': 'input_audio_buffer.append', 'audio': base64.encode(bytes)});
  }

  /// Clears the server's input audio buffer (useful to discard echo after AI speaks).
  void clearInputAudio() {
    _send({'type': 'input_audio_buffer.clear'});
  }

  // ── Response control ─────────────────────────────────────────────────────────

  /// Asks the server to generate a response.
  /// If [force] is true any in-flight response is cancelled first.
  void createResponse({bool force = false}) {
    if (_isResponseActive) {
      if (force) {
        if (debug) log('[RealtimeWS] Cancelling active response to force new one');
        cancelResponse();
      } else {
        if (debug) log('[RealtimeWS] Response already active ($_activeResponseId), skipping');
        return;
      }
    }
    _send({'type': 'response.create'});
  }

  /// Cancels the active server response (no-op when none is active).
  void cancelResponse() {
    if (!_isResponseActive) return;
    _send({'type': 'response.cancel'});
  }

  // ── Conversation item helpers ────────────────────────────────────────────────

  /// Injects a user text turn into the conversation without audio.
  void sendUserMessage(String text) => _sendConversationMessage(role: 'user', text: text, isOutput: false);

  /// Injects an assistant text turn (used to replay context messages).
  void sendAssistantMessage(String text) => _sendConversationMessage(role: 'assistant', text: text, isOutput: true);

  /// Injects a system instruction turn.
  void sendSystemMessage(String text) => _sendConversationMessage(role: 'system', text: text, isOutput: false);

  void _sendConversationMessage({required String role, required String text, required bool isOutput}) {
    final value = text.trim();
    if (value.isEmpty) return;
    _send({
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': role,
        'content': [
          {'type': isOutput ? 'output_text' : 'input_text', 'text': value},
        ],
      },
    });
  }

  /// Returns the result of a tool call back to the server so the model can
  /// continue generating its response.
  void _sendFunctionCallOutput(String callId, String output) {
    _send({
      'type': 'conversation.item.create',
      'item': {'type': 'function_call_output', 'call_id': callId, 'output': output},
    });
  }

  // ── Internal transport ───────────────────────────────────────────────────────

  void _send(Map<String, dynamic> msg) {
    final ws = _ws;
    if (ws == null || !_isConnected) return;
    try {
      ws.sink.add(jsonEncode(msg));
    } catch (e) {
      log('[RealtimeWS] send error: $e');
    }
  }

  // ── Inbound message dispatcher ───────────────────────────────────────────────

  void _handleMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String?;
      // Suppress audio-delta noise from the debug log.
      if (debug && type != 'response.output_audio.delta') {
        log('[RealtimeWS] ← $type');
      }

      switch (type) {
        // ── Response lifecycle ───────────────────────────────────────────────
        case 'response.created':
          _isResponseActive = true;
          _activeResponseId = msg['response']?['id'] as String?;
          break;

        case 'response.done':
          _isResponseActive = false;
          _activeResponseId = null;
          onResponseDone?.call();
          break;

        case 'response.cancelled':
          _isResponseActive = false;
          _activeResponseId = null;
          break;

        // ── Error handling ───────────────────────────────────────────────────
        case 'error':
          final err = msg['error'];
          final code = err?['code'];
          final message = err?['message'];
          if (debug) log('[RealtimeWS] server error: $err');

          // Sync local state without surfacing noise to the UI for benign races.
          if (code == 'response_cancel_not_active') {
            _isResponseActive = false;
            _activeResponseId = null;
            return;
          }
          if (code == 'conversation_already_has_active_response') {
            _isResponseActive = true;
            return;
          }
          onError?.call(message ?? err?.toString() ?? 'unknown error');
          break;

        // ── Audio output ─────────────────────────────────────────────────────
        case 'response.output_audio.delta':
        case 'response.audio.delta':
          final delta = msg['delta'] as String?;
          if (delta != null && delta.isNotEmpty) {
            try {
              onAudioDelta?.call(base64.decode(delta));
            } catch (e) {
              log('[RealtimeWS] audio decode error: $e');
            }
          }
          break;

        case 'response.output_audio.done':
        case 'response.audio.done':
          onAudioDone?.call();
          break;

        // ── Assistant transcript (streaming + final) ─────────────────────────
        case 'response.output_audio_transcript.delta':
        case 'response.audio_transcript.delta':
          _emitTranscript(msg, 'assistant', isFinal: false);
          break;

        case 'response.output_audio_transcript.done':
        case 'response.audio_transcript.done':
          _emitTranscript(msg, 'assistant', isFinal: true);
          break;

        // ── User audio transcript (multilingual, auto-detects language) ──────
        case 'conversation.item.input_audio_transcription.delta':
          _emitTranscript(msg, 'user', isFinal: false);
          break;

        case 'conversation.item.input_audio_transcription.completed':
          _emitTranscript(msg, 'user', isFinal: true);
          break;

        // ── VAD speech start ─────────────────────────────────────────────────
        case 'input_audio_buffer.speech_started':
          onSpeechStarted?.call();
          break;

        // ── Tool call (function call arguments fully assembled) ──────────────
        case 'response.function_call_arguments.done':
          final name = msg['name'] as String?;
          final callId = msg['call_id'] as String?;
          final argsRaw = msg['arguments'] as String?;
          if (name != null && callId != null) {
            unawaited(_handleToolCall(name, callId, argsRaw ?? '{}'));
          }
          break;
      }
    } catch (e) {
      log('[RealtimeWS] handle error: $e');
    }
  }

  /// Forwards a transcript event to [onTranscriptUpdated]. The delta/done
  /// event payloads differ only in which field carries the text.
  void _emitTranscript(Map<String, dynamic> msg, String role, {required bool isFinal}) {
    final text = msg[isFinal ? 'transcript' : 'delta'] as String?;
    final itemId = msg['item_id'] as String?;
    if (text != null && itemId != null) {
      onTranscriptUpdated?.call(role, text, itemId, isFinal);
    }
  }

  // ── Tool dispatch ────────────────────────────────────────────────────────────

  /// Looks up the registered callback for [name], invokes it with [argsRaw]
  /// decoded as a Map, then sends the result back to the server so the model
  /// can continue generating speech.
  Future<void> _handleToolCall(String name, String callId, String argsRaw) async {
    final cb = _toolCallbacks[name];
    if (cb == null) {
      log('[RealtimeWS] tool not registered: $name');
      _sendFunctionCallOutput(callId, jsonEncode({'error': 'tool $name not registered'}));
      createResponse();
      return;
    }
    try {
      final decoded = jsonDecode(argsRaw);
      final args = (decoded is Map) ? decoded.cast<String, dynamic>() : <String, dynamic>{};
      final result = await cb(args);
      _sendFunctionCallOutput(callId, jsonEncode(result));
      // force=true so any lingering response is replaced with the tool's follow-up.
      createResponse(force: true);
    } catch (e) {
      log('[RealtimeWS] tool $name error: $e');
      _sendFunctionCallOutput(callId, jsonEncode({'error': e.toString()}));
      createResponse(force: true);
    }
  }

  // ── Disconnect ───────────────────────────────────────────────────────────────

  /// Closes the WebSocket and clears all registered tools and callbacks.
  Future<void> disconnect() async {
    _isConnected = false;
    await _sub?.cancel();
    _sub = null;
    try {
      await _ws?.sink.close();
    } catch (_) {}
    _ws = null;
    _toolDefs.clear();
    _toolCallbacks.clear();
  }
}
