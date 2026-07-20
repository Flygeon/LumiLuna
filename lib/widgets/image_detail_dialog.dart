import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_item.dart';
import '../providers/media_metadata_provider.dart';

/// Shows detailed information about an image file, including EXIF metadata.
class ImageDetailDialog extends ConsumerWidget {
  final MediaItem item;

  const ImageDetailDialog({super.key, required this.item});

  static Future<void> show(BuildContext context, MediaItem item) {
    return showDialog(
      context: context,
      builder: (_) => ImageDetailDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final metadataAsync = ref.watch(mediaMetadataProvider(item.path));

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('图片详情', style: textTheme.titleLarge),
              const SizedBox(height: 16),

              // Thumbnail preview
              if (item.thumbnailPath != null || item.path != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      item.thumbnailPath != null
                          ? File(item.thumbnailPath!)
                          : File(item.path),
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // File Information section
              _SectionHeader(title: '文件信息', icon: Icons.description_outlined),
              _InfoRow(label: '文件名', value: item.name),
              _InfoRow(label: '路径', value: item.path),
              _InfoRow(label: '大小', value: _formatSize(item.size)),
              _InfoRow(label: '修改时间', value: _formatDate(item.modified)),

              // Resolution and EXIF metadata (lazily loaded)
              metadataAsync.when(
                data: (metadata) {
                  final exifRows = <Widget>[];
                  if (metadata?.imageWidth != null ||
                      metadata?.imageHeight != null) {
                    exifRows.add(_InfoRow(
                      label: '分辨率',
                      value:
                          '${metadata?.imageWidth ?? '?'} × ${metadata?.imageHeight ?? '?'}',
                    ));
                  }
                  if (metadata?.imageDateTaken != null) {
                    exifRows.add(_InfoRow(
                        label: '拍摄日期', value: metadata!.imageDateTaken!));
                  }
                  if (metadata?.imageCameraMake != null ||
                      metadata?.imageCameraModel != null) {
                    exifRows.add(_InfoRow(
                      label: '相机型号',
                      value:
                          '${metadata?.imageCameraMake ?? ''} ${metadata?.imageCameraModel ?? ''}'
                              .trim(),
                    ));
                  }
                  if (metadata?.imageIso != null) {
                    exifRows.add(
                        _InfoRow(label: 'ISO', value: '${metadata!.imageIso}'));
                  }
                  if (metadata?.imageFocalLength != null) {
                    exifRows.add(_InfoRow(
                      label: '焦距',
                      value:
                          '${metadata!.imageFocalLength!.toStringAsFixed(1)} mm',
                    ));
                  }
                  if (metadata?.imageFNumber != null) {
                    exifRows.add(_InfoRow(
                      label: '光圈',
                      value:
                          'f/${metadata!.imageFNumber!.toStringAsFixed(1)}',
                    ));
                  }
                  if (metadata?.imageGpsLat != null &&
                      metadata?.imageGpsLng != null) {
                    exifRows.add(_InfoRow(
                      label: 'GPS 坐标',
                      value:
                          '${metadata!.imageGpsLat!.toStringAsFixed(4)}, ${metadata.imageGpsLng!.toStringAsFixed(4)}',
                    ));
                  }

                  if (exifRows.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '无可用 EXIF 数据',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24),
                      _SectionHeader(
                          title: 'EXIF 元数据',
                          icon: Icons.camera_alt_outlined),
                      ...exifRows,
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '加载 EXIF 数据失败',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
