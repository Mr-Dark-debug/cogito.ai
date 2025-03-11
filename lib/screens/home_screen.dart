import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/paper.dart';
import '../services/arxiv_service.dart';
import '../widgets/loading_indicator.dart';
import 'pdf_viewer_screen.dart';
import 'web_viewer_screen.dart';
import 'collections_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ArxivService _arxivService = ArxivService();
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, ArxivPaper> _pagingController = PagingController(firstPageKey: 0);
  bool _isSearching = false;
  bool _showFilters = false;
  String? _currentQuery;
  bool _showAbstracts = true;
  int _currentIndex = 0;
  String? _selectedCategory;
  
  final List<String> _suggestedCategories = [
    'cs.AI',
    'cs.CL',
    'cs.CV',
    'cs.LG',
    'cs.NE',
    'physics',
    'math',
  ];

  final Map<String, String> _categoryNames = {
    'cs.AI': 'Artificial Intelligence',
    'cs.CL': 'Computation and Language',
    'cs.CV': 'Computer Vision',
    'cs.LG': 'Machine Learning',
    'cs.NE': 'Neural Computing',
    'physics': 'Physics',
    'math': 'Mathematics',
  };

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _arxivService.searchPapers(
        searchQuery: _currentQuery ?? '',
        category: _selectedCategory,
        start: pageKey,
        maxResults: 10,
      );

      final isLastPage = newItems.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });

    _pagingController.refresh();

    setState(() {
      _isSearching = false;
      _showFilters = false;
    });
  }
  
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _currentQuery = '';
      _searchController.clear();
      _isSearching = true;
    });
    
    _pagingController.refresh();
    
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentIndex == 0 ? _buildHomeContent() : const CollectionsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF9C27B0),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Collections',
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          if (_showFilters) _buildFilterPanel(),
          _buildSuggestedCategories(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: _isSearching
                  ? const LoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: () => Future.sync(() => _pagingController.refresh()),
                      child: PagedListView<int, ArxivPaper>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<ArxivPaper>(
                          itemBuilder: (context, paper, index) => _PaperCard(
                            paper: paper,
                            showAbstract: _showAbstracts,
                            onToggleAbstract: () {
                              setState(() {
                                _showAbstracts = !_showAbstracts;
                              });
                            },
                          ),
                          firstPageErrorIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading papers: ${_pagingController.error}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _pagingController.refresh(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No papers found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_currentQuery != null && _currentQuery!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search query',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cogito.ai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.smart_toy, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search papers...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                  onPressed: _onSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _showFilters ? const Color(0xFF9C27B0) : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Research Papers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Show abstract',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showAbstracts,
                    onChanged: (value) {
                      setState(() {
                        _showAbstracts = value;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestedCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4A55A2) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _categoryNames[category] ?? category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A55A2).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _pagingController.refresh();
                  });
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Color(0xFF9C27B0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Year',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: 'All',
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['All', '2024', '2023', '2022', '2021', '2020']
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ))
                            .toList(),
                        onChanged: (value) {
                          // Handle year filter
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: 'Relevance',
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['Relevance', 'Date', 'Citations']
                            .map((sort) => DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort),
                                ))
                            .toList(),
                        onChanged: (value) {
                          // Handle sort filter
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Computer Science',
              'Mathematics',
              'Physics',
              'Economics',
              'Biology'
            ].map((category) {
              final isSelected = false; // TODO: Implement category selection
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  // Handle category selection
                },
                backgroundColor: Colors.grey[100],
                selectedColor: const Color(0xFFE6EEFF),
                checkmarkColor: const Color(0xFF4A55A2),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF4A55A2) : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }
}

class _PaperCard extends StatelessWidget {
  final ArxivPaper paper;
  final bool showAbstract;
  final VoidCallback onToggleAbstract;

  const _PaperCard({
    required this.paper,
    required this.showAbstract,
    required this.onToggleAbstract,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: paper.authors.map((author) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A55A2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Published: ${paper.published}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (showAbstract) ...[
                  const SizedBox(height: 8),
                  Text(
                    paper.summary,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [paper.primaryCategory].map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EEFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(
                    showAbstract ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  label: Text(showAbstract ? 'Hide Abstract' : 'Show Abstract'),
                  onPressed: onToggleAbstract,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // TODO: Implement save to collection
                      },
                      tooltip: 'Save to Collection',
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              pdfUrl: paper.pdfUrl,
                              title: paper.title,
                            ),
                          ),
                        );
                      },
                      tooltip: 'View PDF',
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewerScreen(
                              url: paper.webUrl,
                              title: paper.title,
                            ),
                          ),
                        );
                      },
                      tooltip: 'Open in Web',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}