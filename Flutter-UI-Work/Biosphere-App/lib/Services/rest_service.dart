import 'package:http/http.dart' as http;
import '../Export/export.dart';

enum Method { post, get, put, delete }

class RestService extends GetConnect {
  static Future<http.Response> getResponse({
    String? path,
    Method? method,
    String? body,
  }) async {
    http.Response response;
    if (method == Method.post || method == Method.put) {
      debugPrint(path!);
      if (method == Method.post) {
        response = await http.post(
          Uri.parse(ServiceConfiguration.baseUrl + path),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Settings.accessToken}',
          },
          body: body,
        );
      } else {
        response = await http.put(
          Uri.parse(ServiceConfiguration.baseUrl + path),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Settings.accessToken}',
          },
          body: body,
        );
      }
    } else if (method == Method.delete) {
      response = await http.delete(
        Uri.parse(ServiceConfiguration.baseUrl + path!),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Settings.accessToken}',
        },
      );
    } else {
      debugPrint(path!);
      response = await http.get(
        Uri.parse(ServiceConfiguration.baseUrl + path),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Settings.accessToken}',
        },
      );
    }

    return response;
  }
}
