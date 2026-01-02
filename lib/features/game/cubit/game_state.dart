import 'package:equatable/equatable.dart';
import 'package:serr/core/models/player.dart';
import 'package:serr/core/models/topic.dart';

enum GameStage { setup, reveal, playing }

class GameState extends Equatable {
  final List<Player> players;
  final Topic? currentTopic;
  final GameStage stage;
  final Map<String, String> playerRoles; // playerId -> role (spy or word)
  final int currentPlayerIndex;

  const GameState({
    this.players = const [],
    this.currentTopic,
    this.stage = GameStage.setup,
    this.playerRoles = const {},
    this.currentPlayerIndex = 0,
  });

  GameState copyWith({
    List<Player>? players,
    Topic? currentTopic,
    GameStage? stage,
    Map<String, String>? playerRoles,
    int? currentPlayerIndex,
  }) {
    return GameState(
      players: players ?? this.players,
      currentTopic: currentTopic ?? this.currentTopic,
      stage: stage ?? this.stage,
      playerRoles: playerRoles ?? this.playerRoles,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    );
  }

  @override
  List<Object?> get props =>
      [players, currentTopic, stage, playerRoles, currentPlayerIndex];
}
