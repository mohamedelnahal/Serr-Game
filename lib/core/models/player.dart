import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int avatarColor;

  @HiveField(3)
  final String? imagePath;

  Player({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.imagePath,
  });
}
