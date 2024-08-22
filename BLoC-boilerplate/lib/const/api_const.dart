const String baseUrl = "Your Base URL";
const String baseVersionUrl = "${baseUrl}apiv2/";

class ApiEndpoint {
  static const String login = "$baseUrl Your Login API URL";
}

class ResponseParam {
  static const String status = "status";
  static const String statusCode = "statusCode";
  static const String data = "data";
  static const String token = "token";
  static const String error = "error";
  static const String tokenRefresh = "token_refresh";
  static const String message = "message";
}

enum ApiMethod { post, get }
