import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final int color;

  const Tag({this.id, required this.name, this.color = 0xFF5C5C5C});

  Color get colorValue => Color(color);

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'color': color,
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as int?,
        name: json['name'] as String,
        color: (json['color'] as int?) ?? 0xFF5C5C5C,
      );

  Tag copyWith({int? id, String? name, int? color}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  @override
  bool operator ==(Object other) => other is Tag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
