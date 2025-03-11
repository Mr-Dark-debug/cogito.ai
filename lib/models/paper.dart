import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

class ArxivPaper {
  final String id;
  final String title;
  final List<String> authors;
  final List<String> authorAffiliations;
  final String summary;
  final DateTime published;
  final DateTime updated;
  final List<String> categories;
  final String primaryCategory;
  final String? comment;
  final String? journalRef;
  final String? doi;
  final String pdfUrl;
  final String webUrl;

  ArxivPaper({
    required this.id,
    required this.title,
    required this.authors,
    this.authorAffiliations = const [],
    required this.summary,
    required this.published,
    required this.updated,
    required this.categories,
    required this.primaryCategory,
    this.comment,
    this.journalRef,
    this.doi,
    required this.pdfUrl,
    required this.webUrl,
  });

  factory ArxivPaper.fromXml(xml.XmlElement entry) {
    try {
      // Extract ID
      final idElement = entry.getElement('id');
      if (idElement == null) {
        throw Exception('Missing id element in arXiv entry');
      }
      final id = idElement.innerText;
      final arxivId = id.split('/').last;
      
      // Extract title
      final titleElement = entry.getElement('title');
      if (titleElement == null) {
        throw Exception('Missing title element in arXiv entry');
      }
      final title = titleElement.innerText.trim();
      
      // Extract authors
      final authorElements = entry.findElements('author').toList();
      final authors = authorElements
          .map<String>((author) {
            final nameElement = author.getElement('name');
            return nameElement != null ? nameElement.innerText : 'Unknown Author';
          })
          .toList();
      
      // Extract author affiliations
      final authorAffiliations = authorElements
          .expand((author) => author.findElements('arxiv:affiliation')
              .map((affiliation) => affiliation.innerText.trim()))
          .toList();
      
      // Extract summary
      final summaryElement = entry.getElement('summary');
      final summary = summaryElement != null ? summaryElement.innerText.trim() : 'No summary available';
      
      // Extract dates
      final publishedElement = entry.getElement('published');
      final published = publishedElement != null 
          ? DateTime.parse(publishedElement.innerText) 
          : DateTime.now();
      
      final updatedElement = entry.getElement('updated');
      final updated = updatedElement != null 
          ? DateTime.parse(updatedElement.innerText) 
          : DateTime.now();
      
      // Extract categories
      final categoryElements = entry.findElements('category').toList();
      final categories = categoryElements
          .map<String>((category) => category.getAttribute('term') ?? 'uncategorized')
          .toList();
      
      // Extract primary category
      final primaryCategoryElement = entry.getElement('arxiv:primary_category');
      final primaryCategory = primaryCategoryElement != null 
          ? primaryCategoryElement.getAttribute('term') ?? 'uncategorized'
          : (categories.isNotEmpty ? categories.first : 'uncategorized');
      
      // Extract optional elements
      final commentElement = entry.getElement('arxiv:comment');
      final comment = commentElement?.innerText?.trim();
      
      final journalRefElement = entry.getElement('arxiv:journal_ref');
      final journalRef = journalRefElement?.innerText?.trim();
      
      final doiElement = entry.getElement('arxiv:doi');
      final doi = doiElement?.innerText?.trim();
      
      return ArxivPaper(
        id: arxivId,
        title: title,
        authors: authors,
        authorAffiliations: authorAffiliations,
        summary: summary,
        published: published,
        updated: updated,
        categories: categories,
        primaryCategory: primaryCategory,
        comment: comment,
        journalRef: journalRef,
        doi: doi,
        pdfUrl: 'https://arxiv.org/pdf/$arxivId.pdf',
        webUrl: 'https://arxiv.org/abs/$arxivId',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing ArxivPaper from XML: $e');
      }
      rethrow;
    }
  }

  String get formattedDate {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(published);
  }

  String get authorText {
    if (authors.isEmpty) return '';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return '${authors.first} and ${authors.last}';
    return '${authors.first} et al.';
  }
}