import 'dart:math';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:ludo_app/app/data/board_constants.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';

enum GameState { rolling, moving, finished }

class LudoController extends GetxController {
  late GameMode gameMode;

  // Set by LudoGame after onLoad - triggers AI token movement
  Function(TokenModel)? onComputerMoveRequest;
  // Set by LudoGame after onLoad - resets token visuals
  Function()? onGameReset;

  final players = <PlayerModel>[].obs;
  final currentTurn = 0.obs;
  final diceValue = 1.obs;
  final isRolling = false.obs;
  final gameState = GameState.rolling.obs;
  final winners = <LudoColor>[].obs;
  Worker? _autoPlayWorker;
  int _autoPlayRequestId = 0;

  List<PlayerModel> get activePlayers => players.where((p) => p.isActive).toList();

  PlayerModel get currentPlayer => activePlayers[currentTurn.value % activePlayers.length];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    gameMode = (args?['mode'] as GameMode?) ?? GameMode.fourPlayers;
    _initPlayers();

    // Automate computer turns whenever turn/state changes to a CPU rolling state.
    _autoPlayWorker = everAll([currentTurn, gameState], (_) {
      _scheduleComputerAutoRoll();
    });
  }

  void _initPlayers() {
    switch (gameMode) {
      case GameMode.vsComputer:
        players.assignAll([
          PlayerModel(color: LudoColor.red, name: 'You', playerType: PlayerType.human),
          PlayerModel(color: LudoColor.green, name: 'CPU 1', playerType: PlayerType.computer),
          PlayerModel(color: LudoColor.yellow, name: 'CPU 2', playerType: PlayerType.computer),
          PlayerModel(color: LudoColor.blue, name: 'CPU 3', playerType: PlayerType.computer),
        ]);
        break;
      case GameMode.twoPlayers:
        players.assignAll([
          PlayerModel(color: LudoColor.red, name: 'Player 1'),
          PlayerModel(color: LudoColor.green, name: 'Inactive', isActive: false),
          PlayerModel(color: LudoColor.yellow, name: 'Player 2'),
          PlayerModel(color: LudoColor.blue, name: 'Inactive', isActive: false),
        ]);
        break;
      case GameMode.threePlayers:
        players.assignAll([
          PlayerModel(color: LudoColor.red, name: 'Player 1'),
          PlayerModel(color: LudoColor.green, name: 'Player 2'),
          PlayerModel(color: LudoColor.yellow, name: 'Player 3'),
          PlayerModel(color: LudoColor.blue, name: 'Inactive', isActive: false),
        ]);
        break;
      case GameMode.fourPlayers:
        players.assignAll([
          PlayerModel(color: LudoColor.red, name: 'Player 1'),
          PlayerModel(color: LudoColor.green, name: 'Player 2'),
          PlayerModel(color: LudoColor.yellow, name: 'Player 3'),
          PlayerModel(color: LudoColor.blue, name: 'Player 4'),
        ]);
        break;
    }
  }

  // Called by LudoGame after it is fully loaded and callbacks are set
  void startGame() {
    _scheduleComputerAutoRoll();
  }

  void _scheduleComputerAutoRoll() {
    if (gameState.value != GameState.rolling) return;
    if (currentPlayer.playerType != PlayerType.computer) return;

    final requestId = ++_autoPlayRequestId;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (requestId != _autoPlayRequestId) return;
      if (gameState.value != GameState.rolling) return;
      if (currentPlayer.playerType != PlayerType.computer) return;
      rollDice();
    });
  }

  void rollDice() async {
    if (gameState.value != GameState.rolling || isRolling.value) return;

    isRolling.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    diceValue.value = Random().nextInt(6) + 1;
    // diceValue.value = 6;
    isRolling.value = false;

    final canMove = _checkIfAnyTokenCanMove();
    if (!canMove) {
      await Future.delayed(const Duration(milliseconds: 800));
      nextTurn();
    } else {
      gameState.value = GameState.moving;
      if (currentPlayer.playerType == PlayerType.computer) {
        await Future.delayed(const Duration(milliseconds: 700));
        _executeComputerMove();
      }
    }
  }

  void _executeComputerMove() {
    final best = _pickBestComputerToken();
    if (best != null && onComputerMoveRequest != null) {
      onComputerMoveRequest!(best);
    } else {
      nextTurn();
    }
  }

  TokenModel? _pickBestComputerToken() {
    final movable = currentPlayer.tokens.where((t) => canMoveToken(t)).toList();
    if (movable.isEmpty) return null;

    // Priority 1: Kill an opponent
    for (var t in movable) {
      if (_wouldKillOpponent(t)) return t;
    }

    // Priority 2: Move most advanced token on path
    final onPath = movable.where((t) => t.state == TokenState.path).toList();
    if (onPath.isNotEmpty) {
      return onPath.reduce((a, b) => a.position > b.position ? a : b);
    }

    // Priority 3: Exit base
    return movable.first;
  }

  bool _wouldKillOpponent(TokenModel token) {
    Offset targetPos;

    if (token.state == TokenState.base) {
      // Landing on the starting cell when exiting base
      final startIdx = BoardConstants.startIndexes[token.color]!;
      targetPos = BoardConstants.commonPath[startIdx];
    } else {
      final nextStep = token.position + diceValue.value;
      if (nextStep >= 51) return false; // Home path is safe
      final startIdx = BoardConstants.startIndexes[token.color]!;
      targetPos = BoardConstants.commonPath[(startIdx + nextStep) % 52];
    }

    if (BoardConstants.safeSpots.contains(targetPos)) return false;

    for (var player in activePlayers) {
      if (player.color == token.color) continue;
      for (var t in player.tokens) {
        if (t.state == TokenState.path && t.position < 51) {
          final opponentStart = BoardConstants.startIndexes[t.color]!;
          final opponentPos = BoardConstants.commonPath[(opponentStart + t.position) % 52];
          if (opponentPos == targetPos) return true;
        }
      }
    }
    return false;
  }

  bool _checkIfAnyTokenCanMove() {
    for (var token in currentPlayer.tokens) {
      if (canMoveToken(token)) return true;
    }
    return false;
  }

  bool canMoveToken(TokenModel token) {
    if (token.state == TokenState.home) return false;
    if (token.state == TokenState.base) return diceValue.value == 6;
    if (token.state == TokenState.path) {
      if (token.position >= 57) return false;
      return (token.position + diceValue.value) <= 57;
    }
    return false;
  }

  void checkWinCondition() {
    for (var player in activePlayers) {
      if (!player.isWinner && player.tokens.every((t) => t.state == TokenState.home)) {
        player.isWinner = true;
        winners.add(player.color);
      }
    }

    final remaining = activePlayers.where((p) => !p.isWinner).length;
    if (remaining <= 1) {
      gameState.value = GameState.finished;
      Future.delayed(const Duration(milliseconds: 800), () => Get.toNamed('/result'));
    }
  }

  void nextTurn() {
    final nonWinners = activePlayers.where((p) => !p.isWinner).toList();
    if (nonWinners.length <= 1) {
      gameState.value = GameState.finished;
      return;
    }

    int idx = currentTurn.value;
    int safety = 0;
    do {
      idx = (idx + 1) % activePlayers.length;
      safety++;
      if (safety > activePlayers.length) break;
    } while (activePlayers[idx].isWinner);

    currentTurn.value = idx;
    gameState.value = GameState.rolling;
  }

  void resetGame() {
    for (var player in players) {
      player.isWinner = false;
      for (var token in player.tokens) {
        token.position = -1;
        token.state = TokenState.base;
      }
    }
    currentTurn.value = 0;
    gameState.value = GameState.rolling;
    winners.clear();

    onGameReset?.call();
  }

  @override
  void onClose() {
    _autoPlayWorker?.dispose();
    super.onClose();
  }
}
