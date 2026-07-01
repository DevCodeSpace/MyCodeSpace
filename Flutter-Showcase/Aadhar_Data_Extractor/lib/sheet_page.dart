import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings.dart';
import 'sheet_controller.dart';

const _sheetId = '1ZxYxI8FytSYJQqI2xbce0KwAZ2f9S2NVQ93JQU7GMOk';
const _sheetUrl = 'https://docs.google.com/spreadsheets/d/1ZxYxI8FytSYJQqI2xbce0KwAZ2f9S2NVQ93JQU7GMOk/edit?gid=0#gid=0';

class SheetPage extends StatefulWidget {
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  late final SheetController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<SheetController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text('Saved Entries'),
        backgroundColor: Colors.blueAccent,

        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.link), tooltip: 'Google Script URL', onPressed: () => _showUrlDialog(context)),
          IconButton(icon: const Icon(Icons.download_rounded), tooltip: 'Export CSV', onPressed: ctrl.exportCsv),
        ],
      ),
      body: Column(
        children: [
          _buildBanner(),
          Expanded(
            child: Obx(() {
              if (ctrl.rows.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No entries yet', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(height: 6),
                      Text('Scan an Aadhaar card and tap Submit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: ctrl.rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final row = ctrl.rows[ctrl.rows.length - 1 - i]; // newest first
                  String v(String col) {
                    final idx = ctrl.headers.indexOf(col);
                    return idx != -1 && idx < row.length ? row[idx] : '';
                  }

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 18, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(v('Name').isEmpty ? '—' : v('Name'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  '**** ${v('Aadhaar Last 4')}',
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _infoRow(Icons.cake_outlined, 'DOB: ${v('DOB')}   |   ${v('Gender')}'),
                          _infoRow(Icons.location_on_outlined, '${v('District')}, ${v('State')} - ${v('Pincode')}'),
                          // if (v('Selected Month').isNotEmpty) _infoRow(Icons.calendar_month_outlined, v('Selected Month')),
                          // if (v('Remark').isNotEmpty) _infoRow(Icons.notes_outlined, v('Remark')),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final hasUrl = Settings.googleScriptUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => _showUrlDialog(context),
      child: Container(
        width: double.infinity,
        color: hasUrl ? Colors.green.shade50 : Colors.orange.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(hasUrl ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, size: 18, color: hasUrl ? Colors.green : Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasUrl ? 'Connected to Google Sheet — every entry will be saved automatically' : 'Google Sheet not connected — tap here to configure',
                style: TextStyle(fontSize: 12, color: hasUrl ? Colors.green.shade700 : Colors.orange.shade700),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: hasUrl ? Colors.green : Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
      ],
    ),
  );

  static const _appsScript = '''
function doPost(e) {
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    const data = JSON.parse(e.postData.contents);

    // Add header row if sheet is empty
    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'Name','DOB','Gender','Care Of','House','Street',
        'Location','District','State','Pincode',
        'Aadhaar Last 4','Timestamp'
      ]);
    }

    sheet.appendRow([
      data.name, data.dob, data.gender, data.careof,
      data.house, data.street, data.location, data.district,
      data.state, data.pincode, data.aadhaarLast4,
   
      new Date().toLocaleString('en-IN')
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({status:'ok'}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch(err) {
    return ContentService
      .createTextOutput(JSON.stringify({status:'error', message: err.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
''';

  void _showUrlDialog(BuildContext context) {
    final urlCtrl = TextEditingController(text: Settings.googleScriptUrl);
    bool showScript = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Google Sheet Setup', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Apps Script Web App URL:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(hintText: 'https://script.google.com/macros/s/...', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.link)),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                // Target sheet info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.table_chart, color: Colors.blueAccent, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Your target Google Sheet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      TextButton.icon(
                        onPressed: () => launchUrl(Uri.parse(_sheetUrl), mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('Open', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), minimumSize: Size.zero),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Setup Steps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                _step('1', 'Tap "Open" above — your sheet will open in the browser'),
                _step('2', 'Click Extensions → Apps Script'),
                _step('3', 'Delete existing code, paste the script shown below'),
                _step('4', 'Click Deploy → New deployment → Web App'),
                _step('5', 'Set "Execute as: Me" and "Who has access: Anyone"'),
                _step('6', 'Deploy → copy the URL → paste it in the field above → tap Save'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setS(() => showScript = !showScript),
                  child: Row(
                    children: [
                      Icon(showScript ? Icons.expand_less : Icons.expand_more, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text(
                        showScript ? 'Hide script' : 'View Apps Script code',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (showScript) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: _appsScript));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Script copied!'), behavior: SnackBarBehavior.floating));
                          },
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('Copy', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero),
                        ),
                        SelectableText(_appsScript, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              onPressed: () {
                Settings.googleScriptUrl = urlCtrl.text.trim();
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL saved! Every new entry will now go to Google Sheet.'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String num, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 1, right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
