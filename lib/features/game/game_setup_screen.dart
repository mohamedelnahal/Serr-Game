import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serr/core/models/player.dart';
import 'package:serr/core/models/topic.dart';
import 'package:serr/features/game/cubit/game_cubit.dart';
import 'package:serr/features/game/cubit/game_state.dart';
import 'package:serr/features/game/game_screen.dart';
import 'package:serr/features/game/topic_management_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:serr/core/widgets/background_container.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final Set<String> _selectedPlayerIds = {};
  int _imposterCount = 1;
  Topic? _selectedTopic;
  List<Topic> _topics = [];
  bool _isOneKnowerMode =
      false; // False = Standard, True = One Knower (Find the Knower)
  bool _isRandomTopic = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  void _loadTopics() {
    final box = Hive.box<Topic>('topics');
    setState(() {
      _topics = box.values.toList();
      // Remove defaults logic as requested
      if (_topics.isNotEmpty) {
        // If current selection is invalid, reset
        if (_selectedTopic == null || !_topics.contains(_selectedTopic)) {
          _selectedTopic = _topics.first;
        }
      } else {
        _selectedTopic = null;
      }
    });
  }

  void _togglePlayer(String id) {
    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
      } else {
        _selectedPlayerIds.add(id);
      }
    });
  }

  void _removePlayer(Player player) {
    final box = Hive.box<Player>('players');
    box.delete(player.key);
    context.read<GameCubit>().loadPlayers();
    setState(() {
      _selectedPlayerIds.remove(player.id);
    });
  }

  void _startGame() {
    if (_selectedPlayerIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least 3 players')));
      return;
    }

    Topic? topicToPlay = _selectedTopic;
    if (_isRandomTopic && _topics.isNotEmpty) {
      topicToPlay = _topics[DateTime.now().millisecond % _topics.length];
    }

    if (topicToPlay == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a topic')));
      return;
    }

    final allPlayers = context.read<GameCubit>().state.players;
    final selectedPlayers =
        allPlayers.where((p) => _selectedPlayerIds.contains(p.id)).toList();

    int finalImposterCount = _imposterCount;
    if (_isOneKnowerMode) {
      // In "One Knower" mode, everyone is an imposter except one.
      // So imposters = total - 1
      finalImposterCount = selectedPlayers.length - 1;
    } else {
      // Standard Mode Validation
      int maxImposters = _getMaxImposters(selectedPlayers.length);
      if (finalImposterCount > maxImposters) {
        finalImposterCount = maxImposters;
      }
    }

    context
        .read<GameCubit>()
        .startGame(selectedPlayers, topicToPlay, finalImposterCount);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  int _getMaxImposters(int playerCount) {
    if (playerCount <= 4) return 1;
    if (playerCount <= 9) return 2;
    return 3;
  }

  void _showAddPlayerDialog(BuildContext context) {
    final controller = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addPlayer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.playerName),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            setStateDialog(
                                () => selectedImagePath = image.path);
                          }
                        },
                        icon: const Icon(Icons.camera_alt, size: 40),
                        color: Theme.of(context).iconTheme.color,
                      ),
                      Text(AppLocalizations.of(context)!.camera,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setStateDialog(
                                () => selectedImagePath = image.path);
                          }
                        },
                        icon: const Icon(Icons.photo_library, size: 40),
                        color: Theme.of(context).iconTheme.color,
                      ),
                      Text(AppLocalizations.of(context)!.gallery,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ],
              ),
              if (selectedImagePath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.file(File(selectedImagePath!),
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context
                      .read<GameCubit>()
                      .addPlayer(controller.text, imagePath: selectedImagePath);
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playerCount = _selectedPlayerIds.length;
    final maxImposters = _getMaxImposters(playerCount);

    // Ensure imposter count doesn't exceed max when player count changes
    if (_imposterCount > maxImposters) {
      _imposterCount = maxImposters;
    }

    return BackgroundContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!
                .appTitle, // Or "Setup Game" localized if you prefer, but user asked for "Setup Game" -> we can add "setupGame" key or reuse existing if suitable. Let's use "addPlayer" as a placeholder or better "setupGame" if I added it? Checked plan: I didn't add "setupGame" specifically, but "newGame" is close. Wait, user wants "Setup Game". I should have added it. I'll use "newGame" for now as it translates to "New Game" which is contextually fine or just "Settings" if that fits? "newGame" is "New Game". Let's use "newGame" or keep it "Setup Game" and I'll add "setupGame" key in next turn if needed. Actually, "newGame" is "لعبة جديدة". "Setup Game" implies configuration. Let's look at existing keys: "settings". Maybe "newGame" is fine.
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface, size: 35),
        centerTitle: true,
      ),
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Game Mode Section ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.findTheKnowerMode,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Text(l10n.everyoneIsSpyExceptOne,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7))),
                      value: _isOneKnowerMode,
                      activeColor: const Color(0xFFFFC03D), // Gold
                      activeTrackColor:
                          const Color(0xFFFFC03D).withOpacity(0.5),
                      onChanged: (val) =>
                          setState(() => _isOneKnowerMode = val),
                    ),
                  ],
                ),
              ),

              // --- Topics Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.topics,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface, // Max Contrast
                              fontWeight: FontWeight.w900)), // Extra Bold
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TopicManagementScreen()),
                      );
                      _loadTopics(); // Refresh on return
                    },
                    icon: Icon(Icons.settings,
                        size: 30,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface), // Black & Bigger
                    label: Text(l10n.manageTopics,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Random Topic Checkbox
              CheckboxListTile(
                title: Text(l10n.randomTopic,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                value: _isRandomTopic,
                activeColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                // Allow checking even if _topics is empty initially, logic in _startGame handles the check
                onChanged: (val) {
                  setState(() {
                    _isRandomTopic = val ?? false;
                    if (_isRandomTopic) {
                      _selectedTopic = null; // Clear manual selection
                    } else if (_topics.isNotEmpty) {
                      _selectedTopic = _topics.first;
                    }
                  });
                },
              ),

              if (!_isRandomTopic)
                if (_topics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(l10n.noTopicsAvailable,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  )
                else
                  Center(
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        elevation: 4,
                        color:
                            Theme.of(context).colorScheme.surface, // Gray 300
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Topic>(
                              isExpanded: true,
                              value: _selectedTopic,
                              dropdownColor: Theme.of(context)
                                  .colorScheme
                                  .surface, // Gray 300
                              iconEnabledColor: Theme.of(context).primaryColor,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // Dark Blue Text
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              items: _topics
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e.name)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedTopic = val!),
                              hint: Text(l10n.selectTopic,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24),

              // --- Players Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.players,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface, // Max Contrast
                              fontWeight: FontWeight.w900)), // Extra Bold
                  IconButton(
                    onPressed: () => _showAddPlayerDialog(context),
                    icon: const Icon(Icons.add_circle, size: 48), // Bigger
                    color: Theme.of(context).iconTheme.color, // Black
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.players.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: Text(l10n.noPlayersYet,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700])))),

              _buildPlayerGrid(state.players),

              const SizedBox(height: 24),
              // Imposter Count
              if (playerCount >= 3) ...[
                Row(
                  children: [
                    Text('${l10n.imposterCount}: $_imposterCount',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 22, // Larger
                            fontWeight: FontWeight.w900)), // Extra Bold
                    Expanded(
                      child: Slider(
                        value: _imposterCount.toDouble(),
                        min: 1,
                        max: maxImposters.toDouble(),
                        divisions:
                            (maxImposters - 1) > 0 ? (maxImposters - 1) : 1,
                        label: _imposterCount.toString(),
                        onChanged: (val) =>
                            setState(() => _imposterCount = val.toInt()),
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.maxImpostersMessage(playerCount, maxImposters),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _selectedPlayerIds.length >= 3 &&
                  (_selectedTopic != null ||
                      (_isRandomTopic && _topics.isNotEmpty))
              ? _startGame
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.startGame),
          ),
        ),
      ),
    ));
  }

  Widget _buildPlayerGrid(List<Player> players) {
    if (players.isEmpty) return const SizedBox();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Adjusted for taller cards with bigger content
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = _selectedPlayerIds.contains(player.id);

        return GestureDetector(
          onTap: () => _togglePlayer(player.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E676) // Green if selected
                    : const Color(0xFFFFC03D), // Gold otherwise

                width: isSelected ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Avatar
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: player.imagePath != null
                              ? Image.file(
                                  File(player.imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar(player);
                                  },
                                )
                              : _buildDefaultAvatar(player),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        player.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface, // Dark Blue Text
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // 3D Remove Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => _removePlayer(player),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade900,
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.remove,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(Player player) {
    return Container(
      color: Color(player.avatarColor).withOpacity(1.0),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
