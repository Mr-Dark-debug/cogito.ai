import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/collection.dart';
import '../models/saved_paper.dart';
import '../services/collection_service.dart';
import 'pdf_viewer_screen.dart';
import 'web_viewer_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> with SingleTickerProviderStateMixin {
  final CollectionService _collectionService = CollectionService();
  late TabController _tabController;
  List<Collection> _collections = [];
  Collection? _selectedCollection;
  List<SavedPaper> _papers = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _initCollections();
  }

  Future<void> _initCollections() async {
    try {
      await _collectionService.init();
      
      if (!mounted) return;
      setState(() {
        _collections = _collectionService.getAllCollections();
        _selectedCollection = _collections.isNotEmpty ? _collections.first : null;
        
        if (_selectedCollection != null) {
          _papers = _collectionService.getPapersInCollection(_selectedCollection!.id);
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing collections: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectCollection(Collection collection) {
    setState(() {
      _selectedCollection = collection;
      _papers = _collectionService.getPapersInCollection(collection.id);
    });
  }

  Future<void> _createCollection() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter a name for your list',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                
                final newCollection = Collection(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  createdAt: DateTime.now(),
                  paperIds: [],
                );
                
                await _collectionService.createCollection(newCollection.id);
                
                if (!mounted) return;
                setState(() {
                  _collections = _collectionService.getAllCollections();
                  _selectedCollection = newCollection;
                  _papers = [];
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCollection(Collection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${collection.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      await _collectionService.deleteCollection(collection.id);
      
      if (!mounted) return;
      setState(() {
        _collections = _collectionService.getAllCollections();
        
        if (_collections.isEmpty) {
          _selectedCollection = null;
          _papers = [];
        } else {
          _selectedCollection = _collections.first;
          _papers = _collectionService.getPapersInCollection(_selectedCollection!.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A55A2)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            const SizedBox(height: 8),
            _buildListInfo(),
            Expanded(
              child: _selectedTabIndex == 0 
                  ? _buildMyListsContent() 
                  : _buildEmptyTabContent(_selectedTabIndex == 1 ? "Collaborated" : "Followed"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: Color(0xFF4A55A2)),
              const SizedBox(width: 16),
              const Text(
                'Library',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: _createCollection,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create New List'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A55A2),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF4A55A2),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF4A55A2),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedTabIndex == 0 ? const Color(0xFFE6EEFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('My Lists'),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedTabIndex == 1 ? const Color(0xFFE6EEFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Collaborated'),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedTabIndex == 2 ? const Color(0xFFE6EEFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Followed'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_collections.length} lists available',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Text(
                  'All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListsContent() {
    if (_collections.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        final collection = _collections[index];
        final paperCount = _collectionService.getPapersInCollection(collection.id).length;
        final isPrivate = index % 2 == 0; // Just for demo, alternate between private and public
        
        return GestureDetector(
          onTap: () {
            _selectCollection(collection);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailScreen(
                  collection: collection,
                  papers: _collectionService.getPapersInCollection(collection.id),
                  onDeletePaper: (paperId) async {
                    await _collectionService.removePaperFromCollection(
                      collection.id,
                      paperId,
                    );
                    setState(() {
                      if (_selectedCollection?.id == collection.id) {
                        _papers = _collectionService.getPapersInCollection(collection.id);
                      }
                    });
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPrivate ? Icons.lock : Icons.public,
                        size: 20,
                        color: const Color(0xFF4A55A2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          collection.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPrivate ? 'Private' : 'Public',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'John Doe${!isPrivate ? " · 👥 ${index + 1}" : ""}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Unread',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A55A2),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.collections_bookmark_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Lists Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a list to save your favorite papers',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createCollection,
            icon: const Icon(Icons.add),
            label: const Text('Create List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A55A2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEmptyTabContent(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_shared, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No $tabName Lists',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tabName == "Collaborated" 
                ? 'Lists shared with you will appear here'
                : 'Lists you follow will appear here',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class CollectionDetailScreen extends StatelessWidget {
  final Collection collection;
  final List<SavedPaper> papers;
  final Function(String) onDeletePaper;

  const CollectionDetailScreen({
    Key? key,
    required this.collection,
    required this.papers,
    required this.onDeletePaper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        backgroundColor: const Color(0xFF4A55A2),
        foregroundColor: Colors.white,
      ),
      body: papers.isEmpty
          ? _buildEmptyCollection()
          : ListView.builder(
              itemCount: papers.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final paper = papers[index];
                return _SavedPaperCard(
                  paper: paper,
                  onRemove: () => onDeletePaper(paper.id),
                  onView: () {
                    if (paper.localPdfPath != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(
                            pdfUrl: paper.localPdfPath!,
                            title: paper.title,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(
                            pdfUrl: paper.pdfUrl,
                            title: paper.title,
                          ),
                        ),
                      );
                    }
                  },
                  onWeb: () {
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
                );
              },
            ),
    );
  }

  Widget _buildEmptyCollection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Papers in this List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save papers from the home screen to add them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SavedPaperCard extends StatelessWidget {
  final SavedPaper paper;
  final VoidCallback onRemove;
  final VoidCallback onView;
  final VoidCallback onWeb;

  const _SavedPaperCard({
    required this.paper,
    required this.onRemove,
    required this.onView,
    required this.onWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        paper.authors,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${paper.publishedDate.day}/${paper.publishedDate.month}/${paper.publishedDate.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Saved ${_formatTimeAgo(paper.savedDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: paper.categories.map((category) {
                    return Chip(
                      label: Text(
                        category,
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF4A55A2),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.web),
                  label: const Text('Web'),
                  onPressed: onWeb,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A55A2),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A55A2),
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: 'Remove from collection',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
