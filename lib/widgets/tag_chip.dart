import 'package:flutter/material.dart';

import '../models/tag.dart';

/// A small Material 3 chip that displays a [Tag].
class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Widget? prefix;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(tag.name),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onDelete,
      avatar:
          prefix ?? CircleAvatar(backgroundColor: tag.colorValue, radius: 5),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
