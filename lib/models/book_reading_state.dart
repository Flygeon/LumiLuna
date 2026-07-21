class BookReadingState {
  final String mediaPath;
  final String? coverPath;
  final double progress;
  final String? epubCfi;
  final int? pdfPage;
  final DateTime updatedAt;

  const BookReadingState({
    required this.mediaPath,
    this.coverPath,
    this.progress = 0,
    this.epubCfi,
    this.pdfPage,
    required this.updatedAt,
  });
}

class BookBookmark {
  final String mediaPath;
  final String locator;
  final String? title;
  final String? excerpt;
  final DateTime createdAt;

  const BookBookmark({
    required this.mediaPath,
    required this.locator,
    this.title,
    this.excerpt,
    required this.createdAt,
  });
}
