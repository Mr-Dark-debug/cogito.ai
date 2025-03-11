import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/paper.dart';

class ArxivService {
  final http.Client _client = http.Client();
  final String _baseUrl = 'https://export.arxiv.org/api/query';
  
  // Dispose method to clean up resources
  void dispose() {
    _client.close();
  }
  
  Future<List<ArxivPaper>> getRecentPapers({
    int start = 0,
    int maxResults = 20,
  }) async {
    try {
      // Get recent papers sorted by submission date
      final url = Uri.parse('$_baseUrl?search_query=all&sortBy=submittedDate&sortOrder=descending&start=$start&max_results=$maxResults');
      
      if (kDebugMode) {
        print('ArXiv API Request: ${url.toString()}');
      }
      
      final response = await _client.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please check your internet connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final xmlString = utf8.decode(response.bodyBytes);
        
        if (kDebugMode) {
          print('ArXiv API Response received: ${xmlString.length} bytes');
        }
        
        return _parseArxivResponse(xmlString);
      } else {
        throw Exception('Failed to fetch papers: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getRecentPapers: $e');
      }
      rethrow;
    }
  }
  
  Future<List<ArxivPaper>> searchPapers({
    String? searchQuery,
    String? category,
    int start = 0,
    int maxResults = 20,
  }) async {
    try {
      // Build the search query
      String query = '';
      
      // Add search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Format the search query properly for arXiv API
        final formattedQuery = searchQuery
            .split(' ')
            .map((term) => term.contains(':') ? term : 'all:$term')
            .join(' AND ');
        
        query = 'search_query=$formattedQuery';
      } else {
        // Default to all papers if no search query
        query = 'search_query=all';
      }
      
      // Add category filter if provided
      if (category != null && category.isNotEmpty) {
        query += '+AND+cat:$category';
      }
      
      // Add start and max_results parameters
      final url = Uri.parse('$_baseUrl?$query&start=$start&max_results=$maxResults&sortBy=submittedDate&sortOrder=descending');
      
      if (kDebugMode) {
        print('ArXiv API Request: ${url.toString()}');
      }
      
      final response = await _client.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please check your internet connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final xmlString = utf8.decode(response.bodyBytes);
        
        if (kDebugMode) {
          print('ArXiv API Response received: ${xmlString.length} bytes');
        }
        
        return _parseArxivResponse(xmlString);
      } else {
        throw Exception('Failed to fetch papers: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in searchPapers: $e');
      }
      rethrow;
    }
  }
  
  List<ArxivPaper> _parseArxivResponse(String xmlString) {
    try {
      if (xmlString.isEmpty) {
        if (kDebugMode) {
          print('Empty XML response from arXiv API');
        }
        return [];
      }
      
      final document = XmlDocument.parse(xmlString);
      final entries = document.findAllElements('entry').toList();
      
      if (kDebugMode) {
        print('Found ${entries.length} entries in arXiv response');
      }
      
      final papers = <ArxivPaper>[];
      
      for (final entry in entries) {
        try {
          final paper = ArxivPaper.fromXml(entry);
          papers.add(paper);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing entry: $e');
          }
          // Continue to next entry
        }
      }
      
      if (kDebugMode) {
        print('ArXiv API Papers parsed: ${papers.length}');
      }
      
      return papers;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing arXiv response: $e');
      }
      return [];
    }
  }
}