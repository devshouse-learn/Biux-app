import 'package:flutter/foundation.dart';
import 'package:biux/features/search/data/repositories/search_repository_impl.dart';
import 'package:biux/features/search/domain/entities/search_result_entity.dart';
import 'package:biux/features/search/domain/repositories/search_repository.dart';

/// Provider de búsqueda global.
class SearchProvider extends ChangeNotifier {
  final SearchRepository _repository;

  SearchProvider({SearchRepository? repository})
    : _repository = repository ?? SearchRepositoryImpl();

  List<SearchResult> _users = [];
  List<SearchResult> _groups = [];
  List<SearchResult> _rides = [];
  bool _isSearching = false;
  String _query = '';

  List<SearchResult> get users => _users;
  List<SearchResult> get groups => _groups;
  List<SearchResult> get rides => _rides;
  bool get isSearching => _isSearching;
  String get query => _query;

  Future<void> search(String query) async {
    _query = query.trim();
    if (_query.length < 2) {
      _users = [];
      _groups = [];
      _rides = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.searchUsers(_query),
        _repository.searchGroups(_query),
        _repository.searchRides(_query),
      ]);

      _users = results[0];
      _groups = results[1];
      _rides = results[2];
    } catch (e) {
      // Keep previous results on error
    }

    _isSearching = false;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _users = [];
    _groups = [];
    _rides = [];
    _isSearching = false;
    notifyListeners();
  }
}
