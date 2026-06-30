import 'package:dio/dio.dart';

class ResumeApiService {
  final Dio dio = Dio();

  Future<List<dynamic>> analyzeResumes(List<Map<String, String>> candidates) async {
    final response = await dio.post('https://airesume.app.n8n.cloud/webhook/resume-analysis', data: {"candidates": candidates});

    if (response.data is List) return response.data as List;
    return [response.data];
  }
}
