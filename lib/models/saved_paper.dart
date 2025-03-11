import 'package:hive/hive.dart';
import 'paper.dart';

part 'saved_paper.g.dart';

@HiveType(typeId: 2)
class SavedPaper {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String authors;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final String pdfUrl;

  @HiveField(5)
  final String webUrl;

  @HiveField(6)
  final List<String> categories;

  @HiveField(7)
  final DateTime publishedDate;

  @HiveField(8)
  final DateTime savedDate;

  @HiveField(9)
  final String? localPdfPath;

  SavedPaper({
    required this.id,
    required this.title,
    required this.authors,
    required this.summary,
    required this.pdfUrl,
    required this.webUrl,
    required this.categories,
    required this.publishedDate,
    required this.savedDate,
    this.localPdfPath,
  });

  factory SavedPaper.fromArxivPaper(ArxivPaper paper) {
    return SavedPaper(
      id: paper.id,
      title: paper.title,
      authors: paper.authorText,
      summary: paper.summary,
      pdfUrl: paper.pdfUrl,
      webUrl: paper.webUrl,
      categories: paper.categories,
      publishedDate: paper.published,
      savedDate: DateTime.now(),
    );
  }
}
