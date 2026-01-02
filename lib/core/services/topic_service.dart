import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic.dart';

class TopicService {
  Future<void> loadTopicsFromAssets(BuildContext context) async {
    try {
      final bundle = DefaultAssetBundle.of(context);
      final manifestContent = await bundle.loadString('AssetManifest.json');
      // Simple regex to find keys in "assets/topics/*.txt"
      final RegExp regExp = RegExp(r'assets/topics/.*\.txt');
      final Iterable<Match> matches = regExp.allMatches(manifestContent);

      final box = Hive.box<Topic>('topics');

      for (final Match m in matches) {
        String path = m.group(0)!;
        String fileName = path.split('/').last.replaceAll('.txt', '');
        // Decode URI component just in case of Arabic chars
        try {
          fileName = Uri.decodeComponent(fileName);
        } catch (_) {}

        // Check availability
        bool exists = box.values.any((t) => t.name == fileName);
        if (!exists) {
          String content = await bundle.loadString(path);
          Topic newTopic = parseTopic(content, fileName);
          if (newTopic.words.length >= 3) {
            box.add(newTopic);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading assets: $e");
    }
  }

  Future<void> fetchTopicsFromFirestore() async {
    try {
      final CollectionReference topicsCollection =
          FirebaseFirestore.instance.collection('topics');
      final QuerySnapshot snapshot = await topicsCollection.get();
      final box = Hive.box<Topic>('topics');

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String name = data['name'] ?? doc.id;
        List<String> words = [];

        if (data['words'] is List) {
          // Flatten the list: split each string by dot and expand
          words = (data['words'] as List)
              .map((e) => e.toString())
              .expand((element) => element.split('.'))
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList();
        } else if (data['content'] is String) {
          // Fallback if stored as dot-separated string
          words = (data['content'] as String)
              .split('.')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList();
        }

        if (words.isNotEmpty) {
          // Check if already exists to update or add
          try {
            final existingTopic = box.values.firstWhere(
              (t) => t.name == name,
            );

            // Update existing topic
            // Since fields are final, we create a new instance and put it at the same key
            final updatedTopic = Topic(
              id: existingTopic.id, // Keep original ID
              name: name,
              words: words,
            );
            await box.put(existingTopic.key, updatedTopic);
          } catch (e) {
            // Topic does not exist, add it
            final newTopic = Topic(
              id: doc.id,
              name: name,
              words: words,
            );
            await box.add(newTopic);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching from Firestore: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  // New method to parse content
  Topic parseTopic(String content, String name) {
    // Content structure: words separated by dots (.)
    List<String> words = content
        .split('.')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    return Topic(
      id: DateTime.now().toIso8601String(),
      name: name,
      words: words,
    );
  }
}
