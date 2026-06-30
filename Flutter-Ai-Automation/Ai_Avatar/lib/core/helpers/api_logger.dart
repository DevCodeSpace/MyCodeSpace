import 'dart:convert';
import 'dart:developer' as developer;

import 'package:intl/intl.dart';

import '../../core/utils/import_to_export.dart';

/// ANSI colors for console
const String redColor = '\x1B[31m';
const String greenColordebug = '\x1B[32m';
const String yellowColor = '\x1B[33m';
const String purpleColor = '\x1B[35m';
const String cyanColor = '\x1B[36m';
const String whiteColor = '\x1B[37m';
const String resetColor = '\x1B[0m';

const String brightBlackColor = '\x1B[90m'; // gray
const String brightRedColor = '\x1B[91m';
const String brightGreenColor = '\x1B[92m';
const String brightYellowColor = '\x1B[93m';
const String brightBlueColor = '\x1B[94m';
const String brightPurpleColor = '\x1B[95m'; // bright magenta
const String brightCyanColor = '\x1B[96m';
const String brightWhiteColor = '\x1B[97m';

void logApiCall(String url, int statusCode, Method method, dynamic inputModel, dynamic responseModel) {
  try {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(now);

    final bool isSuccess = statusCode >= 200 && statusCode < 300;
    final statusEmoji = isSuccess ? '✅' : '❌';
    final statusColor = isSuccess ? greenColordebug : redColor;
    final urlColor = isSuccess ? whiteColor : redColor;

    final methodEmoji = _getMethodEmoji(method);
    final statusCodeStr = '$statusColor$statusEmoji Status: $statusCode$resetColor';
    final urlStr = '$urlColor🔗 URL: $url$resetColor';
    final methodStr = '$brightPurpleColor$methodEmoji Method: ${method.name.toUpperCase()}$resetColor';
    final dateStr = '$brightBlueColor Time: $formattedDate$resetColor';

    const boxWidth = 120;
    final horizontalLine = '─' * (boxWidth - 1);
    final topLine = '┌$horizontalLine';
    final bottomLine = '└$horizontalLine';

    final StringBuffer buffer = StringBuffer();

    buffer.writeln('\n$topLine');
    buffer.writeln('│ $methodStr');
    _appendLongLine(buffer, '│ $urlStr', boxWidth);
    buffer.writeln('│ $statusCodeStr');
    buffer.writeln('│ $dateStr');

    // 🔑 Access Token
    final token = Settings.accessToken;
    if (token.isNotEmpty) {
      buffer.writeln('│ $purpleColor🔑 Access Token: $token$resetColor');
    }

    // 📦 Request Body
    if (inputModel != null) {
      buffer.writeln('│ $yellowColor📦 Payload:$resetColor');
      _appendPrettyJson(buffer, inputModel);
    }

    // 📩 Response Body
    if (responseModel != null) {
      buffer.writeln('│ $greenColordebug📩 Response:$resetColor');
      _appendPrettyJson(buffer, responseModel);
    }

    buffer.write(bottomLine);

    developer.log(buffer.toString(), name: '');
  } catch (e) {
    developer.log('$redColor Error in logApiCall: $e $resetColor', name: '');
  }
}

void _appendPrettyJson(StringBuffer buffer, dynamic data) {
  try {
    dynamic jsonObj;

    if (data is String) {
      try {
        jsonObj = jsonDecode(data);
      } catch (_) {
        buffer.writeln('  $data');
        return;
      }
    } else {
      jsonObj = data;
    }

    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(jsonObj);

    for (final line in pretty.split('\n')) {
      buffer.writeln('  $line'); // no │ for JSON block (cleaner)
    }
  } catch (e) {
    buffer.writeln('  $data');
  }
}

void _appendLongLine(StringBuffer buffer, String text, int boxWidth) {
  final maxLineLength = boxWidth - 2;
  var remainingText = text;

  while (remainingText.isNotEmpty) {
    if (remainingText.length <= maxLineLength) {
      buffer.writeln(remainingText);
      break;
    }
    buffer.writeln(remainingText.substring(0, maxLineLength));
    remainingText = '│ ${remainingText.substring(maxLineLength)}';
  }
}

String _getMethodEmoji(Method method) {
  switch (method) {
    case Method.get:
      return '🔍';
    case Method.post:
      return '📤';
    case Method.put:
      return '🔄';
    case Method.delete:
      return '🗑️';
  }
}
