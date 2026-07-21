import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../providers/media_provider.dart';
import 'book_reader_screen.dart';

class BookShelfView extends ConsumerWidget {
  const BookShelfView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(mediaProvider).whenData(
          (items) => items.where((item) => item.type == MediaType.book).toList(),
        );
    return books.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('扫描文件夹中没有 EPUB 或 PDF 图书'));
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = (constraints.maxWidth / 180).floor().clamp(2, 8);
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 18,
                childAspectRatio: 0.62,
              ),
              itemCount: items.length,
              itemBuilder: (_, index) => _BookCard(item: items[index]),
            );
          },
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final MediaItem item;

  const _BookCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BookReaderScreen(item: item),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: scheme.primaryContainer,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 52, color: scheme.primary),
                    const SizedBox(height: 8),
                    Text(item.extension.toUpperCase(),
                        style: TextStyle(color: scheme.primary)),
                  ],
                ),
              ),
            ),
            Container(
              color: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
