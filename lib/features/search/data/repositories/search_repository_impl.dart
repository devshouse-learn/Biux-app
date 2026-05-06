import 'package:biux/features/search/data/datasources/search_datasource.dart';
import 'package:biux/features/search/domain/entities/search_result_entity.dart';
import 'package:biux/features/search/domain/repositories/search_repository.dart';

/// Implementación del repositorio de búsqueda.
class SearchRepositoryImpl implements SearchRepository {
  final SearchDatasource _datasource;

  SearchRepositoryImpl({SearchDatasource? datasource})
    : _datasource = datasource ?? SearchDatasource();

  @override
  Future<List<SearchResult>> searchUsers(String query, {int limit = 15}) =>
      _datasource.searchUsers(query, limit: limit);

  @override
  Future<List<SearchResult>> searchGroups(String query, {int limit = 15}) =>
      _datasource.searchGroups(query, limit: limit);

  @override
  Future<List<SearchResult>> searchRides(String query, {int limit = 15}) =>
      _datasource.searchRides(query, limit: limit);
}
