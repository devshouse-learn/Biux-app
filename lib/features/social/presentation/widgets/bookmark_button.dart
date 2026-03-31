import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/social/data/datasources/bookmarks_datasource.dart';

/// Botón para guardar/marcar un post (bookmark)
class BookmarkButton extends StatefulWidget {
  final String postId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const BookmarkButton({
    super.key,
    required this.postId,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  final _ds = BookmarksDatasource();
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final result = await _ds.isBookmarked(uid, widget.postId);
    if (mounted) {
      setState(() {
        _isBookmarked = result;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Optimistic update
    setState(() => _isBookmarked = !_isBookmarked);

    final result = await _ds.toggleBookmark(uid, widget.postId);
    if (mounted && result != _isBookmarked) {
      setState(() => _isBookmarked = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return GestureDetector(
      onTap: _toggle,
      child: Icon(
        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: widget.size,
        color: _isBookmarked
            ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
            : (widget.inactiveColor ??
                  Theme.of(context).iconTheme.color ??
                  Colors.grey),
      ),
    );
  }
}
