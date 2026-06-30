import 'dart:convert';
import 'package:dio/dio.dart';

class RestaurantApiService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> sendOrder(String order, {String? tableId}) async {
    final response = await dio.post('https://airesume.app.n8n.cloud/webhook-test/dineassistAiPos', data: {"order": order, "table": tableId});

    final data = response.data;
    print('API response type: ${data.runtimeType}');
    print('API response: $data');

    final map = (data is List ? data[0] : data) as Map<String, dynamic>;

    if (map['error'] == true && map['rawResponse'] is String) {
      // The n8n webhook wraps the real JSON in a markdown code fence string
      String raw = (map['rawResponse'] as String).replaceAll(RegExp(r'```json\s*'), '').replaceAll(RegExp(r'```\s*'), '').trim();
      // LLM sometimes emits unevaluated arithmetic (e.g. "total": 8 * 120 + 3 * 250)
      raw = _resolveArithmetic(raw);
      return jsonDecode(raw) as Map<String, dynamic>;
    }

    return map;
  }

  String _resolveArithmetic(String json) {
    return json.replaceAllMapped(RegExp(r'"(\w+)"\s*:\s*([\d\s()*+\-/]+)(?=[,}\n\r])'), (match) {
      final expr = match.group(2)!.trim();
      if (!expr.contains(RegExp(r'[+\-*/()]'))) return match.group(0)!;
      try {
        final val = _evalExpr(expr);
        final str = val % 1 == 0 ? val.toInt().toString() : val.toString();
        return '"${match.group(1)}": $str';
      } catch (_) {
        return match.group(0)!;
      }
    });
  }

  // Recursive descent parser: handles +, -, *, /, and parentheses
  num _evalExpr(String expr) {
    expr = expr.replaceAll(' ', '');
    var pos = 0;

    late num Function() parseExpr;
    late num Function() parseTerm;
    late num Function() parseFactor;

    parseFactor = () {
      if (pos < expr.length && expr[pos] == '(') {
        pos++;
        final result = parseExpr();
        if (pos < expr.length && expr[pos] == ')') pos++;
        return result;
      }
      final start = pos;
      while (pos < expr.length && expr.codeUnitAt(pos) >= 48 && expr.codeUnitAt(pos) <= 57) {
        pos++;
      }
      return num.parse(expr.substring(start, pos));
    };

    parseTerm = () {
      num result = parseFactor();
      while (pos < expr.length && (expr[pos] == '*' || expr[pos] == '/')) {
        final op = expr[pos++];
        result = op == '*' ? result * parseFactor() : result / parseFactor();
      }
      return result;
    };

    parseExpr = () {
      num result = parseTerm();
      while (pos < expr.length && (expr[pos] == '+' || expr[pos] == '-')) {
        final op = expr[pos++];
        result = op == '+' ? result + parseTerm() : result - parseTerm();
      }
      return result;
    };

    return parseExpr();
  }
}
