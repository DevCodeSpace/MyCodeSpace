/// All API base URLs and endpoint path constants used by the app.
/// Import via the barrel (import_to_export.dart) — never reference this class directly from UI.
class ServiceConfiguration {
  // Production base URL — swap to the demo URL for local/staging testing.
  static const String baseUrl = "https://core-api.govava.com";
  // static const String baseUrl = "https://api.govava.smart-maple.com";
  // EndPoint
  static const String keyWordSearch = "/customer/search/keyword_search";

  // Real Time Conversation
  static const String assistantStart = "/customer/assistant/start";
  static const String assistantRefresh = "/customer/assistant/refresh/";
  static const String assistantContext = "/customer/assistant/context/";
  static const String assistantMemory = "/customer/assistant/memory";
}
