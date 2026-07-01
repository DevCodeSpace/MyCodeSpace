import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'aadhar_model.dart';
import 'settings.dart';

class SheetController extends GetxController {
  RxList<List<String>> rows = <List<String>>[].obs;
  RxList<String> headers = <String>[].obs;

  static const _defaultHeaders = ['Name', 'DOB', 'Gender', 'Care Of', 'House', 'Street', 'Location', 'District', 'State', 'Pincode', 'Aadhaar Last 4'];

  @override
  void onInit() {
    super.onInit();
    if (headers.isEmpty) headers.assignAll(_defaultHeaders);
  }

  List<String> getMonthOptions() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final dt = DateTime(now.year, now.month - i, 1);
      return '${_monthName(dt.month)} ${dt.year}';
    });
  }

  String _monthName(int m) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];

  /// Aadhaar scan ke baad nayi row add karta hai
  void addAadhaarEntry(AadharDataModel data) {
    if (headers.isEmpty) headers.assignAll(_defaultHeaders);

    final row = List<String>.filled(headers.length, '');

    void set(String col, String? val) {
      final idx = headers.indexOf(col);
      if (idx != -1) row[idx] = val ?? '';
    }

    final gender = data.gender == 'M'
        ? 'Male'
        : data.gender == 'F'
        ? 'Female'
        : (data.gender ?? '');

    set('Name', data.name);
    set('DOB', data.dob);
    set('Gender', gender);
    set('Care Of', data.careof);
    set('House', data.house);
    set('Street', data.street);
    set('Location', data.location ?? data.vtc);
    set('District', data.district);
    set('State', data.state);
    set('Pincode', data.pincode);
    set('Aadhaar Last 4', data.aadhaarLast4Digit);

    rows.add(row);

    final url = Settings.googleScriptUrl.trim();
    if (url.isEmpty) {
      Get.snackbar(
        'Google Sheet Not Configured',
        'Open Sheet page > tap the link icon > paste your Apps Script URL',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: Colors.orange.shade800,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      );
      return;
    }
    _postToGoogleSheet(url, {
      'name': data.name ?? '',
      'dob': data.dob ?? '',
      'gender': gender,
      'careof': data.careof ?? '',
      'house': data.house ?? '',
      'street': data.street ?? '',
      'location': data.location ?? data.vtc ?? '',
      'district': data.district ?? '',
      'state': data.state ?? '',
      'pincode': data.pincode ?? '',
      'aadhaarLast4': data.aadhaarLast4Digit ?? '',
    });
  }

  Future<void> _postToGoogleSheet(String url, Map<String, String> payload) async {
    try {
      final client = http.Client();
      try {
        // Step 1: POST to Apps Script — disable auto-redirect so we catch the 302
        final req = http.Request('POST', Uri.parse(url))
          ..headers['Content-Type'] = 'application/json'
          ..followRedirects = false
          ..body = jsonEncode(payload);
        final streamed = await client.send(req);
        final res = await http.Response.fromStream(streamed);

        if (res.statusCode == 200) {
          // Direct response (no redirect)
          _handleResponse(200, res.body);
        } else if ((res.statusCode == 301 || res.statusCode == 302) && res.headers['location'] != null) {
          // Step 2: Script already ran — GET the redirect URL to fetch the response
          final res2 = await client.get(Uri.parse(res.headers['location']!));
          _handleResponse(res2.statusCode, res2.body);
        } else {
          _handleResponse(res.statusCode, res.body);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      Get.snackbar('Google Sheet Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
    }
  }

  void _handleResponse(int statusCode, String body) {
    if (statusCode == 200) {
      Get.snackbar(
        'Google Sheet',
        'Entry saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
    } else if (statusCode == 401 || body.contains('<!DOCTYPE')) {
      Get.snackbar(
        'Google Sheet: Access Denied (401)',
        'Redeploy your Apps Script → set "Who has access" to "Anyone" (not "Anyone with Google account")',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 6),
      );
    } else {
      final preview = body.length > 120 ? '${body.substring(0, 120)}…' : body;
      Get.snackbar(
        'Google Sheet Error (Status $statusCode)',
        preview,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> loadFromUrl(String url) async {
    try {
      if (url.contains('docs.google.com/spreadsheets') && !url.contains('export')) {
        final match = RegExp(r'/d/([a-zA-Z0-9-_]+)').firstMatch(url);
        if (match != null) {
          url = 'https://docs.google.com/spreadsheets/d/${match.group(1)}/export?format=csv&gid=0';
        }
      }
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        _parseCsv(res.body);
      } else {
        Get.snackbar('Error', 'Failed to fetch. Status ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> loadFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['csv']);
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      _parseCsv(utf8.decode(bytes));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _parseCsv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    _applyParsed(lines.map(_splitCsvLine).toList());
  }

  List<String> _splitCsvLine(String line) {
    final out = <String>[];
    final cur = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          cur.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        out.add(cur.toString());
        cur.clear();
      } else {
        cur.write(ch);
      }
    }
    out.add(cur.toString());
    return out.map((s) => s.trim()).toList();
  }

  void _applyParsed(List<List<String>> parsed) {
    if (parsed.isEmpty) return;
    var hdrs = parsed.first.map((e) => e.trim()).toList();
    var dataRows = parsed.length > 1
        ? parsed.sublist(1).map((r) {
            final list = List<String>.from(r);
            while (list.length < hdrs.length) {
              list.add('');
            }
            return list;
          }).toList()
        : <List<String>>[];

    for (var r in dataRows) {
      while (r.length < hdrs.length) {
        r.add('');
      }
    }

    headers.assignAll(hdrs);
    rows.assignAll(dataRows);
  }

  void updateRowField(int rowIndex, String columnName, String value) {
    final idx = headers.indexOf(columnName);
    if (idx == -1) return;
    while (rows[rowIndex].length <= idx) {
      rows[rowIndex].add('');
    }
    rows[rowIndex][idx] = value;

    rows.refresh();
  }

  Future<void> exportCsv() async {
    final csv = _toCsv(headers.toList(), rows.toList());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/aadhaar_entries.csv');
    await file.writeAsBytes(utf8.encode(csv));
    await Share.shareXFiles([XFile(file.path)], text: 'Aadhaar Entries');
  }

  String _toCsv(List<String> hdrs, List<List<String>> rowData) {
    final sb = StringBuffer();
    sb.writeln(hdrs.map(_escapeCsv).join(','));
    for (var r in rowData) {
      sb.writeln(
        hdrs
            .asMap()
            .entries
            .map((e) {
              final val = e.key < r.length ? r[e.key] : '';
              return _escapeCsv(val);
            })
            .join(','),
      );
    }
    return sb.toString();
  }

  String _escapeCsv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
