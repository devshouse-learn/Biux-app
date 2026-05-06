import 'package:biux/features/search/domain/entities/search_result_entity.dart';

/// Interfaz del repositorio de búsqueda.
abstract class SearchRepository {
  Future<List<SearchResult>> searchUsers(String query, {int limit = 15});
  Future<List<SearchResult>> searchGroups(String query, {int limit = 15});
  Future<List<SearchResult>> searchRides(String query, {int limit = 15});
}
