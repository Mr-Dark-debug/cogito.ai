import 'package:hive/hive.dart';

part 'collection.g.dart';

@HiveType(typeId: 1)
class Collection {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final List<String> paperIds;

  Collection({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.paperIds = const [],
  });

  Collection copyWith({
    String? name,
    String? description,
    List<String>? paperIds,
  }) {
    return Collection(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: this.createdAt,
      paperIds: paperIds ?? this.paperIds,
    );
  }
}
