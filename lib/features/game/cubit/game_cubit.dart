import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:serr/core/models/player.dart';
import 'package:serr/core/models/topic.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState());

  void loadPlayers() {
    final box = Hive.box<Player>('players');
    emit(state.copyWith(players: box.values.toList()));
  }

  void addPlayer(String name, {String? imagePath}) {
    if (name.trim().isEmpty) return;
    final player = Player(
      id: DateTime.now().toIso8601String(),
      name: name,
      avatarColor: Random().nextInt(0xFFFFFF),
      imagePath: imagePath,
    );
    final box = Hive.box<Player>('players');
    box.add(player);
    emit(state.copyWith(players: box.values.toList()));
  }

  void startGame(List<Player> selectedPlayers, Topic topic, int imposterCount) {
    if (selectedPlayers.length < 3) return; // Minimum 3 players

    final random = Random();
    final roles = <String, String>{};
    final players = List<Player>.from(selectedPlayers)..shuffle();

    // Assign Imposters
    int assignedImposters = 0;
    while (assignedImposters < imposterCount) {
      final index = random.nextInt(players.length);
      final player = players[index];
      if (!roles.containsKey(player.id)) {
        roles[player.id] = 'spy'; // Magic string for Spy
        assignedImposters++;
      }
    }

    // Assign Citizens
    final word = topic.words[random.nextInt(topic.words.length)];
    for (var player in players) {
      if (!roles.containsKey(player.id)) {
        roles[player.id] = word;
      }
    }

    emit(state.copyWith(
      players: players,
      currentTopic: topic,
      stage: GameStage.reveal,
      playerRoles: roles,
      currentPlayerIndex: 0,
    ));
  }

  void nextPlayer() {
    if (state.currentPlayerIndex < state.players.length - 1) {
      emit(state.copyWith(currentPlayerIndex: state.currentPlayerIndex + 1));
    } else {
      emit(state.copyWith(stage: GameStage.playing));
    }
  }

  void resetGame() {
    emit(state.copyWith(
        stage: GameStage.setup,
        currentPlayerIndex: 0,
        playerRoles: {},
        currentTopic: null));
  }
}
