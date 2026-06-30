import 'dart:convert';

import 'package:ai_avtar_chat/modules/assistant/model/assistant_start_response.dart';
import 'package:http/http.dart' as http;

import '../core/utils/import_to_export.dart';

/// Backend API service for the assistant session lifecycle and context persistence.
///
/// Covers the `/customer/assistant/*` endpoints: starting a session, refreshing
/// the ephemeral realtime token, saving/finalizing the conversation context,
/// and fetching the assistant memory snapshot.
class RealTimeConversationServices {
  RealTimeConversationServices._();

  static const String _baseUrl = ServiceConfiguration.baseUrl;

  /// Assistant endpoints use a dedicated header set because they require specific
  /// CORS origin handling (`Origin: https://demo.govava.com`) and standard JSON
  /// acceptance headers for the AI engine to accept them.
  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Origin': 'https://demo.govava.com',
    'Authorization': 'Bearer ${Settings.accessToken}',
  };

  /// Sends a request to [path], logs the full request/response, and returns the
  /// raw response. Pass [body] as a JSON-encodable map; it is encoded here.
  static Future<http.Response> _request(Method method, String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(_baseUrl + path);
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = method == Method.get
        ? await http.get(uri, headers: _headers)
        : await http.post(uri, headers: _headers, body: encodedBody);
    logApiCall(_baseUrl + path, response.statusCode, method, encodedBody, response.body);
    return response;
  }

  /// Creates a brand-new assistant session and returns the avatar/model/session metadata.
  /// Expected Response: Contains session IDs, WebRTC token (`anamSessionToken`), ephemeral
  /// OpenAI token, system prompts, and pre-defined tools to run the AI session.
  static Future<AssistantStartResponse> startSession() async {
    try {
      final response = await _request(Method.post, ServiceConfiguration.assistantStart);
      return assistantStartResponseFromJson(response.body);
    } catch (e) {
      debugPrint("Error in startSession: $e");
      return AssistantStartResponse(status: false);
    }
  }

  /// Refreshes the ephemeral token before it expires so the realtime session can
  /// continue safely. OpenAI Realtime API tokens expire shortly after generation;
  /// this ensures the connection doesn't drop during long conversations.
  static Future<AssistantStartResponse> refreshToken(String sessionId) async {
    try {
      final response = await _request(Method.post, ServiceConfiguration.assistantRefresh + sessionId);
      return assistantStartResponseFromJson(response.body);
    } catch (e) {
      debugPrint("Error in refreshToken: $e");
      return AssistantStartResponse(status: false);
    }
  }

  /// Persists the running conversation context for the current assistant session.
  /// Called incrementally as the conversation goes on so the backend has a snapshot
  /// of the conversation if the app crashes or the connection is lost.
  static Future<bool> saveContext(String sessionId, List<Map<String, String>> messages) {
    return _postContext(sessionId, {"messages": messages}, caller: 'saveContext');
  }

  /// Marks the assistant session as finished and stores the final transcript and
  /// exit reason. `final: true` tells the backend engine to formally close out
  /// this [sessionId].
  static Future<bool> finalizeSession(String sessionId, {required String reason, required List<Map<String, String>> messages}) {
    return _postContext(sessionId, {"final": true, "reason": reason, "messages": messages}, caller: 'finalizeSession');
  }

  static Future<bool> _postContext(String sessionId, Map<String, dynamic> body, {required String caller}) async {
    try {
      final response = await _request(Method.post, ServiceConfiguration.assistantContext + sessionId, body: body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error in $caller: $e");
      return false;
    }
  }

  /// Fetches the latest assistant memory snapshot from the backend.
  static Future<http.Response> getMemory() async {
    try {
      return await _request(Method.get, ServiceConfiguration.assistantMemory);
    } catch (e) {
      debugPrint("Error in getMemory: $e");
      return http.Response(jsonEncode({"status": false}), 500);
    }
  }
}
