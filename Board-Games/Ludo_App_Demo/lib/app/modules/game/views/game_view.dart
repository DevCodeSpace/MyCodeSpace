import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ludo_game.dart';
import '../controllers/ludo_controller.dart';
import '../../../data/models/ludo_models.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  late final LudoController controller;
  late final LudoGame game;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LudoController());
    game = LudoGame();

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.20, end: 0.50).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF060614), Color(0xFF0F1A3A), Color(0xFF1A2850)], stops: [0.0, 0.5, 1.0]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildPlayerProfile(LudoColor.red), _buildPlayerProfile(LudoColor.green)]),
              ),
              Expanded(
                child: Center(
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: _buildBoardWithGlow()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildPlayerProfile(LudoColor.blue), _buildPlayerProfile(LudoColor.yellow)]),
              ),
              _buildStatusBar(),
            ],
          ),
        ),
      ),
    );
  }

  // Animated pulsing glow ring around the board — color follows current player
  Widget _buildBoardWithGlow() {
    return Obx(() {
      final color = _getColor(controller.currentPlayer.color);
      return AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: _glowAnim.value), blurRadius: 36, spreadRadius: 2),
                BoxShadow(color: color.withValues(alpha: _glowAnim.value * 0.35), blurRadius: 72, spreadRadius: 8),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 0.95,
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: GameWidget(game: game),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _buildIconButton(Icons.arrow_back_ios_new_rounded, () => Get.back()),
          Expanded(
            child: Obx(
              () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.currentPlayer.name}\'s Turn',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _getColor(controller.currentPlayer.color), letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 1),
                    // Color accent line
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 32,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: _getColor(controller.currentPlayer.color),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(color: _getColor(controller.currentPlayer.color).withValues(alpha: 0.7), blurRadius: 6)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildIconButton(Icons.home_rounded, () => Get.offAllNamed('/home')),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }

  Widget _buildPlayerProfile(LudoColor color) {
    return Obx(() {
      final player = controller.players.firstWhere(
        (p) => p.color == color,
        orElse: () => PlayerModel(color: color, name: '', isActive: false),
      );
      final isActive = player.isActive;
      final isCurrentTurn = isActive && controller.currentPlayer.color == color;
      final isCPU = player.playerType == PlayerType.computer;
      final playerColor = _getColor(color);

      if (!isActive) {
        return SizedBox(
          width: 108,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Center(
              child: Text('—', style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 22)),
            ),
          ),
        );
      }

      return SizedBox(
        height: 80,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color == LudoColor.green || color == LudoColor.yellow) isCurrentTurn && !isCPU ? _buildDice() : const SizedBox(width: 68),
            _buildPlayerCard(player, isCurrentTurn, isCPU, playerColor),
            if (color == LudoColor.red || color == LudoColor.blue) isCurrentTurn && !isCPU ? _buildDice() : const SizedBox(width: 68),
          ],
        ),
      );
    });
  }

  Widget _buildPlayerCard(PlayerModel player, bool isCurrentTurn, bool isCPU, Color playerColor) {
    // Reading gameState.value ensures dots rebuild after each token move
    controller.gameState.value;
    final homeCount = player.tokens.where((t) => t.state == TokenState.home).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isCurrentTurn ? playerColor.withValues(alpha: 0.13) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isCurrentTurn ? playerColor : Colors.white.withValues(alpha: 0.08), width: isCurrentTurn ? 2.0 : 1.0),
        boxShadow: isCurrentTurn ? [BoxShadow(color: playerColor.withValues(alpha: 0.30), blurRadius: 18, spreadRadius: 1)] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar / spinner
          if (isCPU && isCurrentTurn)
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(playerColor)))
          else
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: isCurrentTurn ? playerColor.withValues(alpha: 0.20) : Colors.transparent, shape: BoxShape.circle),
              child: Icon(isCPU ? Icons.smart_toy_rounded : Icons.person_rounded, color: isCurrentTurn ? playerColor : Colors.white38, size: 24),
            ),
          const SizedBox(height: 2),
          Text(
            player.name,
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: isCurrentTurn ? playerColor : Colors.white38, letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          // Home token progress dots
          _buildTokenDots(homeCount, playerColor, isCurrentTurn),
        ],
      ),
    );
  }

  Widget _buildTokenDots(int homeCount, Color playerColor, bool isCurrentTurn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < homeCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: filled ? 8 : 6,
          height: filled ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? playerColor : Colors.white.withValues(alpha: isCurrentTurn ? 0.18 : 0.10),
            boxShadow: filled ? [BoxShadow(color: playerColor.withValues(alpha: 0.65), blurRadius: 6)] : [],
          ),
        );
      }),
    );
  }

  Widget _buildDice() {
    return Obx(() {
      final isRolling = controller.isRolling.value;
      final canRoll = controller.gameState.value == GameState.rolling && !isRolling;
      final playerColor = _getColor(controller.currentPlayer.color);

      return GestureDetector(
        onTap: canRoll ? () => controller.rollDice() : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: canRoll ? playerColor.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: canRoll ? playerColor.withValues(alpha: 0.40) : Colors.transparent),
              boxShadow: canRoll ? [BoxShadow(color: playerColor.withValues(alpha: 0.28), blurRadius: 12)] : [],
            ),
            child: AnimatedRotation(
              turns: isRolling ? 2 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutBack,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFE8E8E8)]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                    BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 2, offset: const Offset(-1, -1)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: SizedBox.expand(child: CustomPaint(painter: DicePainter(controller.diceValue.value))),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Obx(() {
        final state = controller.gameState.value;
        final isCPU = controller.currentPlayer.playerType == PlayerType.computer;
        final color = _getColor(controller.currentPlayer.color);
        final isRolling = controller.isRolling.value;
        final diceVal = controller.diceValue.value;

        String message;
        if (state == GameState.finished) {
          message = 'GAME OVER!';
        } else if (isCPU) {
          message = isRolling
              ? '${controller.currentPlayer.name} is rolling...'
              : state == GameState.moving
              ? '${controller.currentPlayer.name} is moving...'
              : '${controller.currentPlayer.name} is thinking...';
        } else {
          message = state == GameState.rolling ? 'TAP DICE TO ROLL!' : 'TAP A TOKEN TO MOVE!';
        }

        IconData leftIcon;
        if (state == GameState.finished) {
          leftIcon = Icons.emoji_events_rounded;
        } else if (state == GameState.rolling) {
          leftIcon = Icons.casino_rounded;
        } else {
          leftIcon = Icons.open_with_rounded;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left badge — dice value or icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.38)),
                ),
                child: Center(
                  child: state == GameState.moving
                      ? Text(
                          '$diceVal',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: color),
                        )
                      : Icon(leftIcon, color: color, size: 17),
                ),
              ),
              const SizedBox(width: 10),
              // Message
              Flexible(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              // Right indicator
              SizedBox(
                width: 20,
                height: 20,
                child: isCPU && state != GameState.finished
                    ? CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color))
                    : state == GameState.finished
                    ? Icon(Icons.star_rounded, color: Colors.amber, size: 18)
                    : Icon(state == GameState.rolling ? Icons.touch_app_rounded : Icons.ads_click_rounded, color: color.withValues(alpha: 0.55), size: 17),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getColor(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFFF4444);
      case LudoColor.green:
        return const Color(0xFF2ECC71);
      case LudoColor.yellow:
        return const Color(0xFFFFD93D);
      case LudoColor.blue:
        return const Color(0xFF3D9BFF);
    }
  }
}

class DicePainter extends CustomPainter {
  final int value;
  DicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFF1A1A2E);
    final dotRadius = size.width * 0.13;
    final padding = size.width * 0.24;
    final center = size.width / 2;

    void drawDot(double x, double y) {
      // Dot shadow
      canvas.drawCircle(Offset(x + 0.5, y + 0.8), dotRadius, Paint()..color = Colors.black.withValues(alpha: 0.25));
      // Main dot
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      // Shine
      canvas.drawCircle(Offset(x - dotRadius * 0.35, y - dotRadius * 0.35), dotRadius * 0.28, Paint()..color = Colors.white.withValues(alpha: 0.45));
    }

    if (value == 1 || value == 3 || value == 5) drawDot(center, center);
    if (value > 1) {
      drawDot(padding, padding);
      drawDot(size.width - padding, size.height - padding);
    }
    if (value > 3) {
      drawDot(size.width - padding, padding);
      drawDot(padding, size.height - padding);
    }
    if (value == 6) {
      drawDot(padding, center);
      drawDot(size.width - padding, center);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
