import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/topic.dart';
import '../../core/services/topic_service.dart';
import '../../core/widgets/background_container.dart';

class TopicManagementScreen extends StatefulWidget {
  const TopicManagementScreen({super.key});

  @override
  State<TopicManagementScreen> createState() => _TopicManagementScreenState();
}

class _TopicManagementScreenState extends State<TopicManagementScreen> {
  final TopicService _topicService = TopicService();
  final TextEditingController _nameController = TextEditingController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Load asset topics when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _topicService.loadTopicsFromAssets(context).then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  void _showAddTopicDialog() {
    _nameController.clear();
    final TextEditingController wordsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Topic"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: "Topic Name", hintText: "e.g. Food"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wordsController,
              decoration: const InputDecoration(
                  labelText: "Words",
                  hintText: "Enter words separated by commad or dots..."),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  wordsController.text.isNotEmpty) {
                // Parse words logic
                final rawText = wordsController.text;
                // Split by dot OR comma
                List<String> words = rawText
                    .split(RegExp(r'[.,]'))
                    .map((w) => w.trim())
                    .where((w) => w.isNotEmpty)
                    .toList();

                if (words.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please enter at least 3 words.')));
                  return;
                }

                final box = Hive.box<Topic>('topics');
                final newTopic = Topic(
                  id: DateTime.now().toIso8601String(),
                  name: _nameController.text,
                  words: words,
                );
                box.add(newTopic);
                Navigator.pop(context); // Close dialog
                setState(() {}); // Refresh list
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void _deleteTopic(Topic topic) {
    topic.delete(); // Hive delete
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Topic>('topics');
    final topics = box.values.toList();

    return BackgroundContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Topics',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
        centerTitle: true,
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, size: 35),
                  color: Colors.black,
                  tooltip: 'Sync from Firebase',
                  onPressed: () async {
                    setState(() => _isSyncing = true);
                    try {
                      await _topicService.fetchTopicsFromFirestore();
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Topics is up to date')),
                      );
                      setState(() {}); // Refresh list
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sync failed: $e')),
                      );
                    } finally {
                      if (context.mounted) setState(() => _isSyncing = false);
                    }
                  },
                ),
        ],
      ),
      body: topics.isEmpty
          ? const Center(child: Text("No topics found. Add one!"))
          : ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(topic.name),
                    subtitle: Text('${topic.words.length} words'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTopic(topic),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTopicDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Topic"),
      ),
    ));
  }
}
