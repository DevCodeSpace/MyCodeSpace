import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A1A), Color(0xFF1E2D5A), Color(0xFF0D0D20)]),
        ),
        child: Stack(
          children: [
            // Decorative background blobs
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF4FACFE).withValues(alpha: 0.08)),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE94560).withValues(alpha: 0.08)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // _buildLogo(),
                    Image.asset('assets/images/image_1.png', height: 200, width: 200),

                    Text(
                      'SELECT GAME MODE',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 4),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                      children: [
                        _buildModeCard(
                          title: 'VS COMPUTER',
                          subtitle: 'You vs 3 AI',
                          icon: Icons.smart_toy_rounded,
                          gradientColors: [const Color(0xFFE94560), const Color(0xFFC62A47)],
                          playerSlots: [_SlotType.human, _SlotType.cpu, _SlotType.cpu, _SlotType.cpu],
                          onTap: () => Get.toNamed('/game', arguments: {'mode': GameMode.vsComputer}),
                        ),
                        _buildModeCard(
                          title: '2 PLAYERS',
                          subtitle: 'Head-to-head',
                          icon: Icons.people_alt_rounded,
                          gradientColors: [const Color(0xFF4FACFE), const Color(0xFF0072FF)],
                          playerSlots: [_SlotType.human, _SlotType.empty, _SlotType.human, _SlotType.empty],
                          onTap: () => Get.toNamed('/game', arguments: {'mode': GameMode.twoPlayers}),
                        ),
                        _buildModeCard(
                          title: '3 PLAYERS',
                          subtitle: '3-way battle',
                          icon: Icons.group_rounded,
                          gradientColors: [const Color(0xFF43E97B), const Color(0xFF0BA360)],
                          playerSlots: [_SlotType.human, _SlotType.human, _SlotType.human, _SlotType.empty],
                          onTap: () => Get.toNamed('/game', arguments: {'mode': GameMode.threePlayers}),
                        ),
                        _buildModeCard(
                          title: '4 PLAYERS',
                          subtitle: 'Full battle',
                          icon: Icons.groups_rounded,
                          gradientColors: [const Color(0xFFFFD93D), const Color(0xFFFF8C00)],
                          playerSlots: [_SlotType.human, _SlotType.human, _SlotType.human, _SlotType.human],
                          onTap: () => Get.toNamed('/game', arguments: {'mode': GameMode.fourPlayers}),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text('LUDO KINGDOM  v1.0', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.2), fontSize: 11, letterSpacing: 3)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: const Color(0xFF4FACFE).withValues(alpha: 0.45), blurRadius: 32, spreadRadius: 4)],
          ),
          child: const Icon(Icons.grid_4x4_rounded, size: 52, color: Colors.white),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFFFFFFFF), Color(0xFFFFD93D)]).createShader(bounds),
          child: Text(
            'LUDO',
            style: GoogleFonts.outfit(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8),
          ),
        ),
        Text(
          'KINGDOM',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.yellowAccent.withValues(alpha: 0.85), letterSpacing: 10),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required List<_SlotType> playerSlots,
    required VoidCallback onTap,
  }) {
    final slotColors = [const Color(0xFFFF3D3D), const Color(0xFF2ECC71), const Color(0xFFFFD93D), const Color(0xFF3498DB)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientColors[0].withValues(alpha: 0.12), gradientColors[1].withValues(alpha: 0.04)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gradientColors[0].withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: gradientColors[0].withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final slot = playerSlots[i];
                final color = slotColors[i];
                IconData slotIcon;
                Color slotColor;
                if (slot == _SlotType.human) {
                  slotIcon = Icons.person_rounded;
                  slotColor = color;
                } else if (slot == _SlotType.cpu) {
                  slotIcon = Icons.smart_toy_rounded;
                  slotColor = color;
                } else {
                  slotIcon = Icons.remove_rounded;
                  slotColor = Colors.white.withValues(alpha: 0.15);
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: slot != _SlotType.empty ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: slot != _SlotType.empty ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Icon(slotIcon, size: 12, color: slotColor),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SlotType { human, cpu, empty }
