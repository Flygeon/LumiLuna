import '../models/media_item.dart';

class Playlist {
  final int? id;
  final String name;
  final String? description;
  final String? coverPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MediaItem>? items;

  const Playlist({
    this.id,
    required this.name,
    this.description,
    this.coverPath,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  int get itemCount => items?.length ?? 0;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'coverPath': coverPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as int?,
        name: json['name'] as String,
        description: json['description'] as String?,
        coverPath: json['coverPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    String? coverPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MediaItem>? items,
  }) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        coverPath: coverPath ?? this.coverPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        items: items ?? this.items,
      );

  @override
  bool operator ==(Object other) => other is Playlist && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
