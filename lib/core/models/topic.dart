import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
class Topic extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> words;

  Topic({
    required this.id,
    required this.name,
    required this.words,
  });
}
