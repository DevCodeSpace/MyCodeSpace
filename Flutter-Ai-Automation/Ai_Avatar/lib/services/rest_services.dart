import 'dart:convert';
import 'dart:io';

import 'package:ai_avtar_chat/core/utils/import_to_export.dart';
import 'package:ai_avtar_chat/modules/assistant/model/gift_card_keyword_search_model.dart';
import 'package:http/http.dart' as http;

enum Method { post, get, put, delete }

/// Core networking service.
/// Handles base HTTP operations (GET, POST, PUT, DELETE) and standardizes header
/// injection, including the API key and Authorization token.
class RestService {
  RestService._();

  // Proprietary API key required by the Govava backend for authentication.
  static const String _apiKey = 'cd7b2ec7da86576ea1ea08ab00f7b7d5d609d841e6fbcbf24f2c6f6fb7c0611e';

  /// The backend authenticates POST/PUT by API key alone; GET and DELETE
  /// additionally require the user's bearer token.
  static Map<String, String> _headers(Method method) => {
    'Content-Type': 'application/json',
    'X-Api-Key': _apiKey,
    if (method == Method.get || method == Method.delete) 'Authorization': 'Bearer ${Settings.accessToken}',
  };

  /// Centralized request dispatcher.
  /// Sends [body] (already JSON-encoded) to [path] with the standard headers and
  /// logs the full request/response lifecycle via `logApiCall`.
  static Future<http.Response> getResponse({required String path, required Method method, String? body}) async {
    final uri = Uri.parse(ServiceConfiguration.baseUrl + path);
    final headers = _headers(method);
    final response = switch (method) {
      Method.post => await http.post(uri, headers: headers, body: body),
      Method.put => await http.put(uri, headers: headers, body: body),
      Method.delete => await http.delete(uri, headers: headers),
      Method.get => await http.get(uri, headers: headers),
    };
    logApiCall(ServiceConfiguration.baseUrl + path, response.statusCode, method, body, response.body);
    return response;
  }

  /// Calls POST /customer/search/keyword_search and returns parsed gift products.
  /// Returns an empty response model on network failure or non-200 status.
  static Future<GiftCardKeywordSearchResponseModel> giftKeyWordSearch(GiftCardKeywordSearchInputModel inputModel) async {
    try {
      final response = await getResponse(method: Method.post, path: ServiceConfiguration.keyWordSearch, body: inputModel.toJsonString());
      if (response.statusCode == HttpStatus.ok) {
        return GiftCardKeywordSearchResponseModel.fromJson(jsonDecode(response.body));
      }
      debugPrint('giftKeyWordSearch: HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('giftKeyWordSearch error: $e');
    }
    return GiftCardKeywordSearchResponseModel();
  }
}
