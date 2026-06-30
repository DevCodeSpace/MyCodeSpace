import 'dart:io';

import 'package:ai_omr_check/model/omr_result_model.dart';
import 'package:dio/dio.dart';

class OmrApiService {
  final Dio dio = Dio();

  Future<List<OMRResultResponse>> uploadOmrSheets({required List<File> files, required String examName, required String answerKey}) async {
    FormData formData = FormData();

    formData.fields.add(MapEntry('examName', examName));

    formData.fields.add(MapEntry('answerKey', answerKey));

    for (File file in files) {
      formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)));
    }

    final response = await dio.post('https://airesume.app.n8n.cloud/webhook-test/omr-evaluation', data: formData);

    return (response.data as List).map((e) => OMRResultResponse.fromJson(e)).toList();
  }
}
