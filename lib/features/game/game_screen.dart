import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scratcher/scratcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serr/features/game/cubit/game_cubit.dart';
import 'package:serr/features/game/cubit/game_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'dart:math';
import 'package:serr/core/widgets/background_container.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  bool _isReadyToReveal = false;
  final GlobalKey<ScratcherState> _scratcherKey = GlobalKey<ScratcherState>();
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _nextTurn() {
    _flipController.reset(); // Reset card flip
    setState(() {
      _isReadyToReveal = false;
    });
    context.read<GameCubit>().nextPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        if (state.stage == GameStage.playing) {
          // Everyone revealed, start timer or just show "Who is the spy?"
          return BackgroundContainer(
              child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(leading: const SizedBox()), // Hide back button
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.whoIsTheSpy,
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 30),
                  Stack(
                    children: [
                      // Black Border
                      Text(
                        l10n.donotLetThemCatchYou,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.black,
                            ),
                      ),
                      // Red Fill
                      Text(
                        l10n.donotLetThemCatchYou,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      context.read<GameCubit>().resetGame();
                      Navigator.pop(context);
                    },
                    child: Text(l10n.newGame,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ));
        }

        final currentPlayer = state.players[state.currentPlayerIndex];
        final role = state.playerRoles[currentPlayer.id];
        final isSpy = role == 'spy';

        return BackgroundContainer(
            child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(l10n.appTitle),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isReadyToReveal) ...[
                  // "Pass to [Name]" state
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: currentPlayer.imagePath != null
                            ? Image.file(
                                File(currentPlayer.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person,
                                      size: 60,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface);
                                },
                              )
                            : Container(
                                color: Color(currentPlayer.avatarColor)
                                    .withOpacity(1.0),
                                child: Center(
                                  child: Text(
                                    currentPlayer.name.isNotEmpty
                                        ? currentPlayer.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.passTo(currentPlayer.name),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isReadyToReveal = true;
                      });
                    },
                    child: Text(l10n.ready,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  // Reveal state
                  Expanded(
                    child: Center(
                      child: _buildFlipCard(currentPlayer, role ?? '', isSpy,
                          state.playerRoles, state.players),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.scratchToReveal,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24, // Even Larger
                          fontWeight: FontWeight.w900)), // Extra Bold
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16)),
                    onPressed: _nextTurn,
                    child: Text(l10n.nextPlayer,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ],
            ),
          ),
        ));
      },
    );
  }

  Widget _buildFlipCard(player, String role, bool isSpy,
      Map<String, String> playerRoles, List<dynamic> allPlayers) {
    return GestureDetector(
      onTap: () {
        if (_flipController.isDismissed) {
          _flipController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value;
          final isBack = angle >= pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBackCard(
                        role, isSpy, playerRoles, allPlayers, player),
                  )
                : Image.asset('assets/card_front.png',
                    width: 350, height: 220, fit: BoxFit.fill),
          );
        },
      ),
    );
  }

  Widget _buildBackCard(
      String role,
      bool isSpy,
      Map<String, String> playerRoles,
      List<dynamic> allPlayers,
      dynamic currentPlayer) {
    final l10n = AppLocalizations.of(context)!;
    final revealText = isSpy ? l10n.youAreTheSpy : '${l10n.yourWordIs}\n$role';

    List<String> otherSpies = [];
    if (isSpy) {
      otherSpies = playerRoles.entries
          .where(
              (entry) => entry.value == 'spy' && entry.key != currentPlayer.id)
          .map((entry) {
            final p = allPlayers.where((p) => p.id == entry.key).firstOrNull;
            return p != null ? p.name : '';
          })
          .where((name) => name.isNotEmpty)
          .cast<String>()
          .toList();
    }

    return Scratcher(
      key: _scratcherKey,
      brushSize: 50,
      threshold: 50,
      image: Image.asset('assets/card_back.png', fit: BoxFit.cover),
      onChange: (value) {},
      onThreshold: () {},
      child: Container(
        height: 220,
        width: 350,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSpy ? Icons.warning : Icons.assignment,
                size: 60, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              revealText,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (isSpy && otherSpies.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.spyWith(otherSpies.join(', ')),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w900), // Extra Bold
              )
            ]
          ],
        ),
      ),
    );
  }
}
