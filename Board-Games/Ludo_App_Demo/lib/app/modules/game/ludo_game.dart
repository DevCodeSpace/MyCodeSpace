import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:get/get.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';
import 'controllers/ludo_controller.dart';
import 'components/board_component.dart';
import 'components/token_component.dart';

class LudoGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late BoardComponent board;
  final LudoController controller = Get.find<LudoController>();

  double cellSize = 0;

  @override
  Future<void> onLoad() async {
    cellSize = size.x / 15;

    board = BoardComponent();
    add(board);

    // Only add tokens for active players
    for (var player in controller.players) {
      if (!player.isActive) continue;
      for (var token in player.tokens) {
        add(TokenComponent(token));
      }
    }

    // Set up AI move callback
    controller.onComputerMoveRequest = (token) {
      final tokenComp = children.whereType<TokenComponent>().toList().firstWhereOrNull((t) => t.token == token);
      if (tokenComp != null) {
        tokenComp.moveSteps(controller.diceValue.value);
      } else {
        // Fallback if component not found yet
        Future.delayed(const Duration(milliseconds: 200), () {
          final retryComp = children.whereType<TokenComponent>().toList().firstWhereOrNull((t) => t.token == token);
          retryComp?.moveSteps(controller.diceValue.value);
        });
      }
    };

    // Set up visual reset callback
    controller.onGameReset = () {
      for (var tokenComp in children.whereType<TokenComponent>()) {
        tokenComp.resetPosition();
      }
    };

    // Kick off the first turn (auto-rolls if first player is CPU)
    controller.startGame();
  }

  int _lastTurn = -1;
  GameState? _lastState;

  @override
  void update(double dt) {
    super.update(dt);

    if (controller.currentTurn.value != _lastTurn || controller.gameState.value != _lastState) {
      _lastTurn = controller.currentTurn.value;
      _lastState = controller.gameState.value;
      _refreshHighlights();
    }
  }

  void _refreshHighlights() {
    final isMoving = controller.gameState.value == GameState.moving;
    final isHuman = controller.currentPlayer.playerType == PlayerType.human;

    for (var tokenComp in children.whereType<TokenComponent>()) {
      final isCurrentPlayer = tokenComp.token.color == controller.currentPlayer.color;
      final canMove = controller.canMoveToken(tokenComp.token);

      if (isCurrentPlayer && isMoving && canMove && isHuman) {
        tokenComp.startHighlight();
      } else {
        tokenComp.stopHighlight();
      }
    }
  }

  void onTokenTapped(TokenComponent tokenComponent) {
    // Block input during computer turn
    if (controller.currentPlayer.playerType == PlayerType.computer) return;

    if (controller.gameState.value == GameState.moving && tokenComponent.token.color == controller.currentPlayer.color) {
      if (controller.canMoveToken(tokenComponent.token)) {
        tokenComponent.moveSteps(controller.diceValue.value);
      }
    }
  }
}
