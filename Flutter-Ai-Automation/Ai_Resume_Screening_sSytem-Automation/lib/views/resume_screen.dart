import 'package:ai_resume_demo/controller/resume_controller.dart';
import 'package:ai_resume_demo/views/widgets/modern_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ResumeScreen extends StatelessWidget {
  ResumeScreen({super.key});

  final ResumeController controller = Get.put(ResumeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  _buildUploadSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  _buildResultsHeader(),
                ],
              ),
            ),
          ),
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/banner.png', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8), Theme.of(context).scaffoldBackgroundColor],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resume AI',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideX(begin: -0.2),
        Text(
          'Next-gen candidate screening powered by Intelligence.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600)).slideX(begin: -0.2),
      ],
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: controller.pickResumes,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            FaIcon(
              FontAwesomeIcons.cloudArrowUp,
              size: 48,
              color: Colors.cyanAccent,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: const Duration(seconds: 2), color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Upload Resumes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select multiple PDF files to analyze', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.resumes.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${controller.resumes.length} Files Selected',
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ).animate().scale();
            }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400)).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final hasFiles = controller.resumes.isNotEmpty;
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasFiles && !controller.isLoading.value ? controller.analyzeResumes : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: Colors.cyanAccent.withOpacity(0.4),
          ),
          child: controller.isLoading.value
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 18),
                    const SizedBox(width: 12),
                    const Text('START AI ANALYSIS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
        ),
      ).animate().fadeIn(delay: const Duration(milliseconds: 600));
    });
  }

  Widget _buildResultsHeader() {
    return Obx(() {
      if (controller.results.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Screening Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${controller.results.length} Candidates', style: const TextStyle(color: Colors.white54)),
        ],
      ).animate().fadeIn();
    });
  }

  Widget _buildResultsList() {
    return Obx(() {
      if (controller.results.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ModernCandidateCard(candidate: controller.results[index]).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(begin: 0.2);
          }, childCount: controller.results.length),
        ),
      );
    });
  }
}
