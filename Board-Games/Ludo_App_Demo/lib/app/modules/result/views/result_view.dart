import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';
import 'package:ludo_app/app/modules/game/controllers/ludo_controller.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final LudoController controller = Get.find<LudoController>();
    final active = controller.activePlayers;

    // Build full ranking: winners in finish order, then non-winners
    final ranked = <PlayerModel>[
      ...controller.winners.map((c) => active.firstWhere((p) => p.color == c)),
      ...active.where((p) => !p.isWinner),
    ];

    final winner = ranked.isNotEmpty ? ranked.first : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A1A2E), Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Trophy
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 36,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 62, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'GAME OVER',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              if (winner != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${winner.name} WINS!',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getColor(winner.color),
                    letterSpacing: 2,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'FINAL RANKINGS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Rankings list
              ...ranked.asMap().entries.map((e) => _buildRankRow(e.key + 1, e.value)),
              const Spacer(),
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        label: 'HOME',
                        icon: Icons.home_rounded,
                        color: Colors.white.withValues(alpha: 0.12),
                        borderColor: Colors.white.withValues(alpha: 0.2),
                        onTap: () => Get.offAllNamed('/home'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildButton(
                        label: 'PLAY AGAIN',
                        icon: Icons.refresh_rounded,
                        color: const Color(0xFFE94560),
                        borderColor: Colors.transparent,
                        onTap: () {
                          final mode = controller.gameMode;
                          Get.delete<LudoController>(force: true);
                          Get.offNamed('/game', arguments: {'mode': mode});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankRow(int rank, PlayerModel player) {
    final color = _getColor(player.color);
    final isTop = rank == 1;

    final medals = ['🥇', '🥈', '🥉'];
    final medalText = rank <= 3 ? medals[rank - 1] : '#$rank';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isTop ? 0.22 : 0.07),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isTop ? 0.55 : 0.2),
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            medalText,
            style: GoogleFonts.outfit(
              fontSize: isTop ? 28 : 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.outfit(
                    fontSize: isTop ? 19 : 16,
                    fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                    color: isTop ? color : Colors.white70,
                  ),
                ),
                if (player.playerType == PlayerType.computer)
                  Text(
                    'AI Player',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isTop
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFFF3D3D);
      case LudoColor.green:
        return const Color(0xFF2ECC71);
      case LudoColor.yellow:
        return const Color(0xFFFFD93D);
      case LudoColor.blue:
        return const Color(0xFF3498DB);
    }
  }
}
