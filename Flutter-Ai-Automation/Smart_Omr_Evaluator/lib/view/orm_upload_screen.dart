import 'dart:io';

import 'package:ai_omr_check/controller/omr_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OmrUploadScreen extends StatelessWidget {
  OmrUploadScreen({super.key});

  final OmrController controller = Get.put(OmrController());

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle ambient glows for visual depth against light background
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary.withValues(alpha: 0.08)),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: colors.secondary.withValues(alpha: 0.06)),
              ),
            ),

            // Scrollable Content
            Column(
              children: [
                const SizedBox(height: 15),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: _buildHeader(colors)),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputSection(colors),
                          const SizedBox(height: 28),
                          _buildImageSelectionSection(context, colors),
                          const SizedBox(height: 32),
                          _buildUploadButton(colors),
                          const SizedBox(height: 36),
                          _buildResponseSection(colors),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: [
        // Container(
        //   padding: const EdgeInsets.all(10),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(16),
        //     border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
        //     boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 4))],
        //   ),
        //   child: Image.asset(
        //     'assets/images/logo.png',
        //     height: 44,
        //     width: 44,
        //     errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.scanLine, size: 44, color: colors.primary),
        //   ),
        // ),
        // const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart OMR Evaluator',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF0F172A)),
            ),
            // Text(
            //   'AI OMR SCANNER',
            //   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: colors.primary),
            // ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildInputSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.fileSpreadsheet, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            const Text(
              'Exam Configurations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 14),
        _CustomTextField(
          controller: controller.examController,
          label: 'Exam Name',
          icon: LucideIcons.bookmark,
          hint: 'e.g., Final Exam - Biology 101',
          colors: colors,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 14),
        _CustomTextField(
          controller: controller.answerKeyController,
          label: 'Answer Key JSON',
          icon: LucideIcons.keyRound,
          hint: '{"1":"A", "2":"C"}',
          maxLines: 4,
          colors: colors,
        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildImageSelectionSection(BuildContext context, ColorScheme colors) {
    return Obx(() {
      final files = controller.selectedFiles;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.layers, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Scanned Sheets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              if (files.isNotEmpty)
                Text(
                  '${files.length} Selected',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors.primary),
                ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 14),
          if (files.isEmpty)
            GestureDetector(
              onTap: controller.pickFiles,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.06), shape: BoxShape.circle),
                      child: Icon(LucideIcons.imagePlus, size: 36, color: colors.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to upload OMR sheets',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1))
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: files.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.file(File(files[index].path), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                              child: const Icon(LucideIcons.x, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().scale(delay: (40 * index).ms);
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: controller.addMoreFiles,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add More Sheets'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildUploadButton(ColorScheme colors) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [colors.primary, colors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : () => controller.uploadSheets(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.scanFace, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Evaluate OMR Sheets',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
        ),
      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0);
    });
  }

  Widget _buildResponseSection(ColorScheme colors) {
    return Obx(() {
      final results = controller.results;
      if (results.isEmpty) return const SizedBox.shrink();

      // Metrics calculation
      final totalSheets = results.length;
      final parsedAccuracies = results.map((r) => double.tryParse(r.accuracy?.replaceAll('%', '') ?? '0') ?? 0.0).toList();
      final averageAccuracy = totalSheets > 0 ? parsedAccuracies.reduce((a, b) => a + b) / totalSheets : 0.0;
      final highPerformers = parsedAccuracies.where((acc) => acc >= 80.0).length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.pieChart, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Evaluation Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // High Fidelity Analytics Panels
          Row(
            children: [
              // Average Accuracy Widget
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Avg. Accuracy',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: averageAccuracy / 100,
                              strokeWidth: 5,
                              backgroundColor: Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                            ),
                          ),
                          Text(
                            '${averageAccuracy.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Class Stats Widget
              Expanded(
                child: Column(
                  children: [
                    _buildStatMiniCard('Total Scanned', '$totalSheets Sheets', LucideIcons.fileCheck, colors.primary),
                    const SizedBox(height: 8),
                    _buildStatMiniCard('High Scorers', '$highPerformers Students', LucideIcons.award, const Color(0xFF10B981)),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          Row(
            children: [
              Icon(LucideIcons.users, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Student Performance List',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Students List with color coded ratings
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final result = results[index];
              final accuracyNum = double.tryParse(result.accuracy?.replaceAll('%', '') ?? '0') ?? 0.0;

              // Color determination
              Color statusColor;
              IconData statusIcon;
              if (accuracyNum >= 80.0) {
                statusColor = const Color(0xFF10B981); // Excellent Performance
                statusIcon = LucideIcons.checkCircle;
              } else if (accuracyNum >= 50.0) {
                statusColor = const Color(0xFFF59E0B); // Average Performance
                statusIcon = LucideIcons.alertTriangle;
              } else {
                statusColor = const Color(0xFFEF4444); // Needs attention
                statusIcon = LucideIcons.xCircle;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1),
                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    // Dynamic Performance Indicator Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.08), shape: BoxShape.circle),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 14),

                    // Student Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.name ?? 'Student Name N/A',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 3),
                          Text('Roll Number: ${result.rollNumber ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ),
                    ),

                    // Metrics block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${accuracyNum.toStringAsFixed(0)}% Acc',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: statusColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Score: ${result.marks}/${result.totalQuestions}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: 0.05, end: 0, delay: (80 * index).ms);
            },
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1, end: 0);
    });
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon, Color highlightColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightColor.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: highlightColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final ColorScheme colors;

  const _CustomTextField({required this.controller, required this.label, required this.hint, required this.icon, required this.colors, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 12.0) : 0),
            child: Icon(icon, color: colors.primary, size: 18),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
