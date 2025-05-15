import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// A list view that supports pagination and lazy loading
///
/// This widget handles loading more items when the user scrolls to the end of the list.
/// It also supports pull-to-refresh and shows appropriate loading indicators.
class PaginatedListView<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;

  /// Function to build each item in the list
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Function to load more items when the user scrolls to the end of the list
  final Future<void> Function()? onLoadMore;

  /// Function to refresh the list when the user pulls down
  final Future<void> Function()? onRefresh;

  /// Whether there are more items to load
  final bool hasMoreItems;

  /// Whether the list is currently loading more items
  final bool isLoading;

  /// Empty state widget to show when the list is empty
  final Widget? emptyStateWidget;

  /// Error widget to show when there's an error
  final Widget? errorWidget;

  /// Error message to display
  final String? errorMessage;

  /// Scroll controller for the list
  final ScrollController? scrollController;

  /// Scroll physics for the list
  final ScrollPhysics? scrollPhysics;

  /// Padding for the list
  final EdgeInsetsGeometry? padding;

  /// Whether to shrink wrap the list
  final bool shrinkWrap;

  /// Whether to show the loading indicator at the bottom
  final bool showLoadingIndicator;

  /// Whether to show the scroll bar
  final bool showScrollbar;

  /// Whether to enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Separator builder for the list
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Creates a PaginatedListView
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.hasMoreItems = false,
    this.isLoading = false,
    this.emptyStateWidget,
    this.errorWidget,
    this.errorMessage,
    this.scrollController,
    this.scrollPhysics,
    this.padding,
    this.shrinkWrap = false,
    this.showLoadingIndicator = true,
    this.showScrollbar = true,
    this.enablePullToRefresh = true,
    this.separatorBuilder,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_isLoadingMore || !widget.hasMoreItems || widget.onLoadMore == null) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMoreItems || widget.onLoadMore == null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (widget.onRefresh == null) {
      return;
    }

    try {
      await widget.onRefresh!();
    } catch (e) {
      // Error handling is done by the parent widget
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error widget if there's an error
    if (widget.errorMessage != null && widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    // Show empty state if the list is empty and not loading
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyStateWidget ??
          const Center(child: Text('No items found'));
    }

    // Build the list
    Widget listView =
        widget.separatorBuilder != null
            ? ListView.separated(
              controller: _scrollController,
              physics: widget.scrollPhysics,
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              itemCount: widget.items.length + (widget.hasMoreItems ? 1 : 0),
              separatorBuilder: widget.separatorBuilder!,
              itemBuilder: _buildItem,
            )
            : ListView.builder(
              controller: _scrollController,
              physics: widget.scrollPhysics,
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              itemCount: widget.items.length + (widget.hasMoreItems ? 1 : 0),
              itemBuilder: _buildItem,
            );

    // Add pull-to-refresh if enabled
    if (widget.enablePullToRefresh && widget.onRefresh != null) {
      listView = RefreshIndicator(onRefresh: _refresh, child: listView);
    }

    // Add scrollbar if enabled
    if (widget.showScrollbar) {
      listView = Scrollbar(controller: _scrollController, child: listView);
    }

    return listView;
  }

  Widget _buildItem(BuildContext context, int index) {
    // Show loading indicator at the bottom if loading more
    if (index == widget.items.length) {
      if (!widget.showLoadingIndicator) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        alignment: Alignment.center,
        child: const LoadingIndicator(size: 24.0),
      );
    }

    // Build the item
    return widget.itemBuilder(context, widget.items[index], index);
  }
}
