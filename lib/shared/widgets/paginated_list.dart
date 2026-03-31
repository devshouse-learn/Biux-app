
import 'package:flutter/material.dart';

class PaginatedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final int pageSize;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const PaginatedList({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.pageSize = 15,
    this.padding,
    this.physics,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final _scrollController = ScrollController();
  final List<T> _items = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final newItems = await widget.onLoadMore(_page, widget.pageSize);
      setState(() {
        _items.addAll(newItems);
        _page++;
        _hasMore = newItems.length >= widget.pageSize;
        _initialLoading = false;
      });
    } catch (_) {
      setState(() => _initialLoading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> refresh() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _initialLoading = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return widget.emptyWidget ??
          const Center(child: Text('No hay elementos'));
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        itemCount: _items.length + (_loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }
}
