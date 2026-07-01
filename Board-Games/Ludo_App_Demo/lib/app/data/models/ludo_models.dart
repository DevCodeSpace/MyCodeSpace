
enum LudoColor { red, green, yellow, blue }

enum TokenState { base, path, home }

enum PlayerType { human, computer }

enum GameMode { vsComputer, twoPlayers, threePlayers, fourPlayers }

class TokenModel {
  final int id;
  final LudoColor color;
  int position;
  TokenState state;

  TokenModel({
    required this.id,
    required this.color,
    this.position = -1,
    this.state = TokenState.base,
  });
}

class PlayerModel {
  final LudoColor color;
  final String name;
  final List<TokenModel> tokens;
  final PlayerType playerType;
  final bool isActive;
  bool isWinner;

  PlayerModel({
    required this.color,
    required this.name,
    this.playerType = PlayerType.human,
    this.isActive = true,
  })  : tokens = List.generate(4, (i) => TokenModel(id: i, color: color)),
        isWinner = false;
}
