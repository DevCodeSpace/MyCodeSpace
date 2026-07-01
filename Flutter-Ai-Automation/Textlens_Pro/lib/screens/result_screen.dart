import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/scan_result.dart';
import '../utils/app_colors.dart';
import '../widgets/highlighted_text.dart';

class ResultScreen extends StatefulWidget {
  final ScanResult result;
  final String? initialQuery;

  const ResultScreen({
    super.key,
    required this.result,
    this.initialQuery,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _searchCtrl;
  String _query = '';
  int _matchCount = 0;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtrl = TextEditingController(text: _query);
    _recalcMatches(_query);
  }

  void _recalcMatches(String query) {
    if (query.trim().isEmpty) {
      setState(() => _matchCount = 0);
      return;
    }
    final lower = widget.result.fullText.toLowerCase();
    final q = query.toLowerCase();
    int count = 0;
    int idx = 0;
    while ((idx = lower.indexOf(q, idx)) != -1) {
      count++;
      idx += q.length;
    }
    setState(() => _matchCount = count);
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: widget.result.fullText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.accent,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareText() async {
    await Share.share(widget.result.fullText, subject: 'Extracted Text');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Extracted Text'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: widget.result.fullText.isEmpty ? null : _copyText,
            tooltip: 'Copy all',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: widget.result.fullText.isEmpty ? null : _shareText,
            tooltip: 'Share',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: widget.result.fullText.trim().isEmpty
          ? _EmptyState(onBack: () => Navigator.pop(context))
          : Column(
              children: [
                _buildSearchBar(),
                if (_query.isNotEmpty) _buildMatchChip(),
                Expanded(child: _buildTextArea()),
                _buildBottomActions(),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search in extracted text…',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                      _recalcMatches('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (v) {
            setState(() => _query = v);
            _recalcMatches(v);
          },
        ),
      ),
    );
  }

  Widget _buildMatchChip() {
    final hasMatch = _matchCount > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: hasMatch
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hasMatch
                ? '$_matchCount match${_matchCount > 1 ? 'es' : ''} found'
                : 'No matches',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasMatch ? AppColors.primary : Colors.red.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: SelectionArea(
          child: HighlightedText(
            text: widget.result.fullText,
            query: _query,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyText,
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text('Copy All'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareText,
                icon: const Icon(Icons.share_rounded, size: 17),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.text_fields_rounded,
                  size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No text detected',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try scanning a clearer image or\nadjust the camera angle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onBack,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
