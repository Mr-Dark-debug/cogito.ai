import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/collection.dart';
import '../models/saved_paper.dart';
import '../models/paper.dart';

class CollectionService {
  static const String _collectionsBoxName = 'collections';
  static const String _papersBoxName = 'saved_papers';

  late Box<Collection> _collectionsBox;
  late Box<SavedPaper> _papersBox;
  final Dio _dio = Dio();
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CollectionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SavedPaperAdapter());
    }
    
    _collectionsBox = await Hive.openBox<Collection>(_collectionsBoxName);
    _papersBox = await Hive.openBox<SavedPaper>(_papersBoxName);
    
    // Create default collection if none exists
    if (_collectionsBox.isEmpty) {
      await createCollection('Favorites', 'My favorite papers');
    }
  }

  // Collection methods
  Future<Collection> createCollection(String name, [String description = '']) async {
    final collection = Collection(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    
    await _collectionsBox.put(collection.id, collection);
    return collection;
  }

  List<Collection> getAllCollections() {
    return _collectionsBox.values.toList();
  }

  Future<void> updateCollection(Collection collection) async {
    await _collectionsBox.put(collection.id, collection);
  }

  Future<void> deleteCollection(String collectionId) async {
    await _collectionsBox.delete(collectionId);
  }

  // Paper methods
  Future<SavedPaper> savePaper(ArxivPaper paper, String collectionId) async {
    // Check if paper already saved
    final existingPaper = _papersBox.values.firstWhere(
      (p) => p.id == paper.id,
      orElse: () => SavedPaper.fromArxivPaper(paper),
    );
    
    // Save paper if not already saved
    if (!_papersBox.containsKey(existingPaper.id)) {
      await _papersBox.put(existingPaper.id, existingPaper);
    }
    
    // Add paper to collection
    final collection = _collectionsBox.get(collectionId);
    if (collection != null && !collection.paperIds.contains(paper.id)) {
      final updatedCollection = collection.copyWith(
        paperIds: [...collection.paperIds, paper.id],
      );
      await _collectionsBox.put(collectionId, updatedCollection);
    }
    
    return existingPaper;
  }

  Future<void> removePaperFromCollection(String paperId, String collectionId) async {
    final collection = _collectionsBox.get(collectionId);
    if (collection != null && collection.paperIds.contains(paperId)) {
      final updatedCollection = collection.copyWith(
        paperIds: collection.paperIds.where((id) => id != paperId).toList(),
      );
      await _collectionsBox.put(collectionId, updatedCollection);
    }
  }

  List<SavedPaper> getPapersInCollection(String collectionId) {
    final collection = _collectionsBox.get(collectionId);
    if (collection == null) return [];
    
    return collection.paperIds
        .map((id) => _papersBox.get(id))
        .where((paper) => paper != null)
        .cast<SavedPaper>()
        .toList();
  }

  bool isPaperInCollection(String paperId, String collectionId) {
    final collection = _collectionsBox.get(collectionId);
    return collection != null && collection.paperIds.contains(paperId);
  }

  bool isPaperSaved(String paperId) {
    return _papersBox.containsKey(paperId);
  }

  // PDF download methods
  Future<String?> downloadPdf(SavedPaper paper) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDirectory = Directory('${directory.path}/pdfs');
      if (!await pdfDirectory.exists()) {
        await pdfDirectory.create(recursive: true);
      }
      
      final filePath = '${pdfDirectory.path}/${paper.id}.pdf';
      
      // Check if file already exists
      if (await File(filePath).exists()) {
        return filePath;
      }
      
      // Download file
      await _dio.download(
        paper.pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );
      
      // Update paper with local path
      final updatedPaper = SavedPaper(
        id: paper.id,
        title: paper.title,
        authors: paper.authors,
        summary: paper.summary,
        pdfUrl: paper.pdfUrl,
        webUrl: paper.webUrl,
        categories: paper.categories,
        publishedDate: paper.publishedDate,
        savedDate: paper.savedDate,
        localPdfPath: filePath,
      );
      
      await _papersBox.put(paper.id, updatedPaper);
      return filePath;
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }

  void dispose() {
    _collectionsBox.close();
    _papersBox.close();
  }
}
