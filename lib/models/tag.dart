import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final int color;
  final int? parentId;
  final bool isGroup;

  const Tag({
    this.id,
    required this.name,
    this.color = 0xFF5C5C5C,
    this.parentId,
    this.isGroup = false,
  });

  Color get colorValue => Color(color);

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'color': color,
        if (parentId != null) 'parentId': parentId,
        'isGroup': isGroup,
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as int?,
        name: json['name'] as String,
        color: (json['color'] as int?) ?? 0xFF5C5C5C,
        parentId: json['parentId'] as int?,
        isGroup: (json['isGroup'] as bool?) ?? false,
      );

  Tag copyWith({
    int? id,
    String? name,
    int? color,
    int? parentId,
    bool? isGroup,
  }) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        parentId: parentId ?? this.parentId,
        isGroup: isGroup ?? this.isGroup,
      );

  @override
  bool operator ==(Object other) => other is Tag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
