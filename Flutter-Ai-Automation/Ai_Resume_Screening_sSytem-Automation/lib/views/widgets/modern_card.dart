import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../model/resume_result_model.dart';

class ModernCandidateCard extends StatelessWidget {
  final ResumeResultModel candidate;

  const ModernCandidateCard({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircularPercentIndicator(
            radius: 28,
            lineWidth: 5,
            animation: true,
            percent: candidate.score / 100,
            center: Text('${candidate.score}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: _getScoreColor(candidate.score),
            backgroundColor: Colors.white10,
          ),
          title: Text(
            candidate.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          subtitle: Text('Candidate Match', style: TextStyle(color: Colors.white70, fontSize: 13)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  _buildSectionTitle(FontAwesomeIcons.circleCheck, 'Strengths', Colors.greenAccent),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: candidate.strengths.map((s) => _buildChip(s.toString(), Colors.greenAccent)).toList()),
                  const SizedBox(height: 16),
                  _buildSectionTitle(FontAwesomeIcons.circleXmark, 'Areas for Growth', Colors.orangeAccent),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: candidate.weaknesses.map((w) => _buildChip(w.toString(), Colors.orangeAccent)).toList()),
                  if (candidate.questions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle(FontAwesomeIcons.circleQuestion, 'Suggested Interview Questions', Colors.cyanAccent),
                    const SizedBox(height: 8),
                    ...candidate.questions.map(
                      (q) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.cyanAccent)),
                            Expanded(
                              child: Text(q.toString(), style: const TextStyle(fontSize: 13, color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(dynamic icon, String title, Color color) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.blueAccent;
    if (score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
