import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:ludo_app/app/data/board_constants.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';
import 'package:ludo_app/app/modules/game/controllers/ludo_controller.dart';
import '../ludo_game.dart';

class TokenComponent extends PositionComponent with TapCallbacks, HasGameReference<LudoGame> {
  final TokenModel token;
  late _PinVisual _visual;
  _PulsingIndicator? _indicator;
  bool _isMoving = false;

  TokenComponent(this.token) : super();

  @override
  Future<void> onLoad() async {
    final cellSize = game.size.x / 15;
    size = Vector2(cellSize * 0.65, cellSize * 0.9);
    anchor = Anchor.bottomCenter;

    _visual = _PinVisual(color: _getColor(), darkColor: _getDarkColor(_getColor()));
    add(_visual);

    _updatePosition();
  }

  Color _getColor() {
    switch (token.color) {
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

  Color _getDarkColor(Color c) {
    return Color.fromARGB(
      (c.a * 255.0).round().clamp(0, 255),
      (c.r * 255.0 * 0.50).round().clamp(0, 255),
      (c.g * 255.0 * 0.50).round().clamp(0, 255),
      (c.b * 255.0 * 0.50).round().clamp(0, 255),
    );
  }

  void _updatePosition() {
    final cellSize = game.size.x / 15;
    Offset pos;

    if (token.state == TokenState.base) {
      pos = BoardConstants.basePositions[token.color]![token.id];
      position = Vector2(pos.dx * cellSize, pos.dy * cellSize);
    } else if (token.state == TokenState.path) {
      pos = _getPathOffset(token.position);
      position = Vector2((pos.dx * cellSize) + cellSize / 2, (pos.dy * cellSize) + cellSize / 2);
    } else {
      pos = BoardConstants.homeFinishPositions[token.color]![token.id];
      position = Vector2(pos.dx * cellSize, pos.dy * cellSize);
    }
  }

  Offset _getPathOffset(int step) {
    if (step < 52) {
      final startIndex = BoardConstants.startIndexes[token.color]!;
      final commonIndex = (startIndex + step) % 52;
      return BoardConstants.commonPath[commonIndex];
    }
    // step 52 is homePaths[0], step 57 is homePaths[5]
    return BoardConstants.homePaths[token.color]![step - 52];
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onTokenTapped(this);
  }

  void moveSteps(int steps) async {
    final cellSize = game.size.x / 15;
    _isMoving = true;

    // Already finished tokens inside the winning triangle cannot move.
    if (token.state == TokenState.home || token.position >= 57) {
      token.state = TokenState.home;
      _isMoving = false;
      return;
    }

    if (token.state == TokenState.base) {
      if (steps == 6) {
        token.state = TokenState.path;
        token.position = 0;
        await _arcAnimateTo(_getPathOffset(0), cellSize);
        _isMoving = false;
        _onMovementFinished();
      } else {
        _isMoving = false;
      }
      return;
    }

    for (int i = 0; i < steps; i++) {
      token.position++;
      if (token.position >= 57) {
        token.state = TokenState.home;
        final finishPos = BoardConstants.homeFinishPositions[token.color]![token.id];
        await _arcAnimateTo(finishPos, cellSize, isBase: true);
        break;
      }
      await _arcAnimateTo(_getPathOffset(token.position), cellSize);
    }

    _isMoving = false;
    _onMovementFinished();
  }

  Future<void> _arcAnimateTo(Offset offset, double cellSize, {bool isBase = false}) async {
    final target = isBase ? Vector2(offset.dx * cellSize, offset.dy * cellSize) : Vector2((offset.dx * cellSize) + cellSize / 2, (offset.dy * cellSize) + cellSize / 2);

    final start = position.clone();
    final dist = (target - start).length;
    final arcHeight = math.max(cellSize * 0.7, math.min(dist * 0.6, cellSize * 2.4));
    final mid = Vector2((start.x + target.x) / 2, ((start.y + target.y) / 2) - arcHeight);

    // Rise — easeOut gives fast launch
    final up = MoveToEffect(mid, EffectController(duration: 0.11, curve: Curves.easeOut));
    add(up);
    await up.completed;

    // Fall — easeIn gives gravity feel
    final down = MoveToEffect(target, EffectController(duration: 0.12, curve: Curves.easeIn));
    add(down);
    await down.completed;

    // Landing squish
    final squish = ScaleEffect.to(Vector2(1.22, 0.80), EffectController(duration: 0.055, reverseDuration: 0.10, curve: Curves.easeOut));
    add(squish);
    await squish.completed;
    scale = Vector2.all(1.0);
  }

  void _onMovementFinished() {
    _checkCollisions();
    game.controller.checkWinCondition();

    final extraTurn = token.state == TokenState.home || game.controller.diceValue.value == 6 || game.controller.gameState.value == GameState.rolling;

    if (extraTurn) {
      game.controller.gameState.value = GameState.rolling;
    } else {
      game.controller.nextTurn();
    }
  }

  void _checkCollisions() {
    if (token.position >= 51) return;

    final currentGridPos = _getPathOffset(token.position);
    if (BoardConstants.safeSpots.contains(currentGridPos)) return;

    final opponents = game.children.whereType<TokenComponent>().where((t) => t.token.color != token.color);

    for (var opponent in opponents) {
      if (opponent.token.state == TokenState.path && opponent.token.position < 51) {
        final opponentGridPos = opponent._getPathOffset(opponent.token.position);
        if (opponentGridPos == currentGridPos) {
          opponent.sendToBase();
          game.controller.gameState.value = GameState.rolling;
        }
      }
    }
  }

  void resetPosition() {
    removeAll(children.whereType<Effect>());
    stopHighlight();
    scale = Vector2.all(1.0);
    _isMoving = false;
    _updatePosition();
  }

  void sendToBase() {
    stopHighlight();
    token.state = TokenState.base;
    token.position = -1;
    final cellSize = game.size.x / 15;
    final basePos = BoardConstants.basePositions[token.color]![token.id];
    removeAll(children.whereType<Effect>());
    add(MoveToEffect(Vector2(basePos.dx * cellSize, basePos.dy * cellSize), EffectController(duration: 0.55, curve: Curves.easeOutCubic)));
  }

  void startHighlight() {
    if (_indicator != null) return;

    _indicator = _PulsingIndicator(color: _getColor());
    _indicator!.position = Vector2(size.x / 2, size.y);
    add(_indicator!);

    // Bouncing animation for the visual part ONLY
    _visual.add(MoveByEffect(Vector2(0, -cellSize * 0.25), EffectController(duration: 0.45, reverseDuration: 0.45, infinite: true, curve: Curves.easeInOut)));
  }

  double get cellSize => game.size.x / 15;

  void stopHighlight() {
    _indicator?.removeFromParent();
    _indicator = null;

    // Clear animations from visual
    _visual.removeAll(_visual.children.whereType<Effect>());
    _visual.position = Vector2.zero();

    scale = Vector2.all(1.0);
    _updatePosition();
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // 1. Draw grounded shadow (stays at bottomCenter tip even if pin bounces)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h), width: w * 0.65, height: h * 0.15),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }
}

class _PinVisual extends PositionComponent {
  final Color color;
  final Color darkColor;

  _PinVisual({required this.color, required this.darkColor});

  @override
  void onMount() {
    super.onMount();
    size = (parent as PositionComponent).size;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final r = w / 2;
    final centerX = w / 2;
    final topY = r;

    // 1. Proper Pin Geometry Path
    final path = Path();
    final angle = math.pi / 4; // Angle where circle meets triangle base
    final dx = r * math.sin(angle);
    final dy = r * math.cos(angle);

    path.moveTo(centerX, h); // Bottom tip
    path.lineTo(centerX - dx, topY + dy);
    path.arcToPoint(Offset(centerX + dx, topY + dy), radius: Radius.circular(r), clockwise: true, largeArc: true);
    path.close();

    // 2. Draw metallic thickness/rim
    final rimPath = path.shift(const Offset(0.8, 1.2));
    canvas.drawPath(
      rimPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 3. Draw main body with metallic sweep/radial combo
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.1,
          colors: [color.withValues(alpha: 0.85), color, darkColor],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 4. White glossy rim (top edge highlight)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 5. Inner decorative circle (The "Eye")
    final eyeCenter = Offset(centerX, topY);
    final eyeRadius = r * 0.48;
    canvas.drawCircle(
      eyeCenter,
      eyeRadius,
      Paint()
        ..color = Colors.white
        ..shader = RadialGradient(colors: [Colors.white, Colors.white.withValues(alpha: 0.9)]).createShader(Rect.fromCircle(center: eyeCenter, radius: eyeRadius)),
    );

    // 6. Mini pin icon inside the eye (Premium detail)
    _drawMiniPin(canvas, eyeCenter, eyeRadius * 0.55);

    // 7. Glossy bubble on top bulb
    canvas.drawCircle(
      Offset(centerX - r * 0.3, topY - r * 0.3),
      r * 0.25,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.6), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(centerX - r * 0.3, topY - r * 0.3), radius: r * 0.25)),
    );
  }

  void _drawMiniPin(Canvas canvas, Offset center, double size) {
    final h = size;
    final w = size * 0.8;
    final p = Path();
    p.moveTo(center.dx, center.dy + h / 2);
    p.quadraticBezierTo(center.dx - w / 2, center.dy, center.dx, center.dy - h / 2);
    p.quadraticBezierTo(center.dx + w / 2, center.dy, center.dx, center.dy + h / 2);
    canvas.drawPath(p, Paint()..color = color);
  }
}

class _PulsingIndicator extends CircleComponent with HasGameReference<LudoGame> {
  _PulsingIndicator({required Color color})
    : super(
        radius: 0,
        anchor: Anchor.center,
        paint: Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

  @override
  void onLoad() {
    radius = game.size.x / 15 * 0.45;
    add(ScaleEffect.to(Vector2.all(1.6), EffectController(duration: 0.55, reverseDuration: 0.55, infinite: true, curve: Curves.easeInOut)));
    add(OpacityEffect.to(0.1, EffectController(duration: 0.55, reverseDuration: 0.55, infinite: true, curve: Curves.easeInOut)));
  }
}
