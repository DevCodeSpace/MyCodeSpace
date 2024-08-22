import 'dart:developer';
import 'package:bloc_boiler_plate/helper/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpCaller {
  static Future<ResponseModel> login({
    required String url,
    required String username,
    required String password,
    Map<String, String> header = const {},
  }) async {
    final netWorkStatus = await checkInternetConnection();
    if (!netWorkStatus) {
      return ResponseModel(
        isSuccess: false,
        error: "No Internet Connection",
      );
    }

    ResponseModel responseModel = ResponseModel();
    Map<String, String> allHeader = {
      "Content-Type": "application/json",
      "Authorization": Settings.accessToken,
    };
    
    // Merge additional headers if provided
    allHeader.addAll(header);

    // Create the request
    final request = http.Request('POST', Uri.parse(url));
    request.body = jsonEncode({
      "username": username,
      "password": password,
    });
    request.headers.addAll(allHeader);

    // Send the request
    final response = await request.send();
    final dataString = await response.stream.bytesToString();
    Map<String, dynamic> data = jsonDecode(dataString);

    log("==========================");
    log("ENDPOINT : ${url.split("/").last}");
    log("STATUS CODE : ${data["statusCode"]}");
    log("BODY : ${jsonEncode(request.body)}");
    log("RESPONSE : $dataString");
    log("TOKEN : ${Settings.accessToken}");
    log("==========================");

    try {
      // Check for token refresh
      if (data.containsKey("tokenRefresh")) {
        Settings.accessToken = data["tokenRefresh"];
      }
    } catch (e) {
      log("REFRESH TOKEN ERROR : ${e.toString()}");
    }

    if (data["statusCode"] == 200) {
      Settings.accessToken = data["data"]["token"];
      return responseModel.copyWith(isSuccess: true);
    } else {
      return responseModel.copyWith(
        isSuccess: false,
        error: data["error"] ?? "Login failed",
      );
    }
  }

  static Future<bool> checkInternetConnection() async {
    // Implement your internet connection check here
    // For example, using Connectivity package or another method
    return true; // Assuming connection is available
  }
}

class ResponseModel {
  final bool isSuccess;
  final String? error;

  ResponseModel({this.isSuccess = false, this.error});

  ResponseModel copyWith({bool? isSuccess, String? error}) {
    return ResponseModel(
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}