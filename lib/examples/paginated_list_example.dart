import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/paginated_list_view.dart';
import 'package:eventati_book/services/supabase/utils/database_service.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/utils/core/constants.dart';
import 'package:eventati_book/utils/logger.dart';

/// Example screen demonstrating the PaginatedListView widget
class PaginatedListExample extends StatefulWidget {
  /// Creates a PaginatedListExample
  const PaginatedListExample({super.key});

  @override
  State<PaginatedListExample> createState() => _PaginatedListExampleState();
}

class _PaginatedListExampleState extends State<PaginatedListExample> {
  final DatabaseService _databaseService = DatabaseService();
  final String _collection = 'services'; // Example collection

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  bool _hasMoreItems = true;
  String? _errorMessage;
  int _currentPage = 0;
  final int _pageSize = AppConstants.defaultPageSize;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load the first page with count information
      final result = await _databaseService.getCollectionWithCount(
        _collection,
        page: 0,
        pageSize: _pageSize,
      );

      setState(() {
        _items = List<Map<String, dynamic>>.from(result['data']);
        _totalItems = result['count'];
        _hasMoreItems = result['hasMorePages'];
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('Error loading initial data: $e', tag: 'PaginatedListExample');
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMoreItems || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Load the next page
      final nextPage = _currentPage + 1;
      final result = await _databaseService.getCollectionWithCount(
        _collection,
        page: nextPage,
        pageSize: _pageSize,
      );

      final newItems = List<Map<String, dynamic>>.from(result['data']);

      setState(() {
        _items.addAll(newItems);
        _hasMoreItems = result['hasMorePages'];
        _currentPage = nextPage;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('Error loading more data: $e', tag: 'PaginatedListExample');
      setState(() {
        _errorMessage = 'Failed to load more data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      // Reset to the first page
      final result = await _databaseService.getCollectionWithCount(
        _collection,
        page: 0,
        pageSize: _pageSize,
      );

      setState(() {
        _items = List<Map<String, dynamic>>.from(result['data']);
        _totalItems = result['count'];
        _hasMoreItems = result['hasMorePages'];
        _currentPage = 0;
        _errorMessage = null;
      });
    } catch (e) {
      Logger.e('Error refreshing data: $e', tag: 'PaginatedListExample');
      setState(() {
        _errorMessage = 'Failed to refresh data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated List Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Pagination info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Showing ${_items.length} of $_totalItems items',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          // List view
          Expanded(
            child: PaginatedListView<Map<String, dynamic>>(
              items: _items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item['name'] ?? 'Unnamed Item'),
                  subtitle: Text(item['description'] ?? 'No description'),
                  leading:
                      item['image_url'] != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(item['image_url']),
                          )
                          : const CircleAvatar(child: Icon(Icons.image)),
                  onTap: () {
                    // Handle item tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on ${item['name']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
              onLoadMore: _loadMoreData,
              onRefresh: _refreshData,
              hasMoreItems: _hasMoreItems,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              emptyStateWidget: const EmptyState(
                title: 'No Items Found',
                message: 'There are no items to display.',
                icon: Icons.inbox,
              ),
              padding: const EdgeInsets.all(8.0),
              showScrollbar: true,
              enablePullToRefresh: true,
            ),
          ),
        ],
      ),
    );
  }
}
