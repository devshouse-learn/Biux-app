import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/search/domain/entities/search_result_entity.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

/// Datasource de búsqueda que consulta Firestore.
class SearchDatasource {
  final FirebaseFirestore _firestore;

  // Constantes de validación
  static const int MIN_QUERY_LENGTH = 2;
  static const int MAX_QUERY_LENGTH = 100;
  static const int DEFAULT_LIMIT = 15;
  static const int MAX_LIMIT = 100;

  SearchDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// CRÍTICO #6: Valida y sanitiza el query de búsqueda
  String _validateAndSanitizeQuery(String query) {
    if (query.isEmpty) {
      throw ValidationException('query', 'La búsqueda no puede estar vacía');
    }

    if (query.length < MIN_QUERY_LENGTH) {
      throw ValidationException(
        'query',
        'La búsqueda debe tener al menos $MIN_QUERY_LENGTH caracteres',
      );
    }

    if (query.length > MAX_QUERY_LENGTH) {
      throw ValidationException(
        'query',
        'La búsqueda no puede exceder $MAX_QUERY_LENGTH caracteres',
      );
    }

    // Sanitizar: remover caracteres especiales y espacios extras
    final sanitized = query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Múltiples espacios a uno
        .replaceAll(
          RegExp(r'[^\w\s-áéíóúàèìòùäëïöüñ]'),
          '',
        ); // Solo alphanumerics

    if (sanitized.isEmpty) {
      throw ValidationException(
        'query',
        'La búsqueda contiene solo caracteres especiales',
      );
    }

    return sanitized;
  }

  /// Valida el límite de resultados
  int _validateLimit(int limit) {
    if (limit <= 0) {
      return DEFAULT_LIMIT;
    }
    return limit > MAX_LIMIT ? MAX_LIMIT : limit;
  }

  Future<List<SearchResult>> searchUsers(String query, {int limit = 15}) async {
    try {
      // CR\u00cdTICO #6: Validar y sanitizar query
      final sanitizedQuery = _validateAndSanitizeQuery(query);
      final validLimit = _validateLimit(limit);

      AppLogger.info(
        'B\u00fasqueda de usuarios: "$sanitizedQuery" (limit: $validLimit)',
        tag: 'SearchDatasource',
      );

      final snap = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: sanitizedQuery)
          .where('name', isLessThanOrEqualTo: '$sanitizedQuery\uf8ff')
          .limit(validLimit)
          .get();

      AppLogger.debug(
        'Se encontraron ${snap.docs.length} usuarios',
        tag: 'SearchDatasource',
      );

      return snap.docs.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          name: data['name'] ?? data['fullName'] ?? '',
          photoUrl: data['photoUrl'] ?? data['photo'] ?? '',
          subtitle: '@${data['username'] ?? ''}',
          type: SearchResultType.user,
        );
      }).toList();
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validaci\u00f3n fallida en b\u00fasqueda: ${e.message}',
        tag: 'SearchDatasource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error buscando usuarios: $e',
        tag: 'SearchDatasource',
        error: e,
      );
      return [];
    }
  }

  Future<List<SearchResult>> searchGroups(
    String query, {
    int limit = 15,
  }) async {
    try {
      final sanitizedQuery = _validateAndSanitizeQuery(query);
      final validLimit = _validateLimit(limit);

      AppLogger.info(
        'B\u00fasqueda de grupos: "$sanitizedQuery" (limit: $validLimit)',
        tag: 'SearchDatasource',
      );

      final snap = await _firestore
          .collection('groups')
          .where('name', isGreaterThanOrEqualTo: sanitizedQuery)
          .where('name', isLessThanOrEqualTo: '$sanitizedQuery\uf8ff')
          .limit(validLimit)
          .get();

      AppLogger.debug(
        'Se encontraron ${snap.docs.length} grupos',
        tag: 'SearchDatasource',
      );

      return snap.docs.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          name: data['name'] ?? '',
          photoUrl: data['photoUrl'] ?? data['image'] ?? '',
          subtitle: data['city'] ?? '',
          type: SearchResultType.group,
        );
      }).toList();
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validaci\u00f3n fallida en b\u00fasqueda: ${e.message}',
        tag: 'SearchDatasource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error buscando grupos: $e',
        tag: 'SearchDatasource',
        error: e,
      );
      return [];
    }
  }

  Future<List<SearchResult>> searchRides(String query, {int limit = 15}) async {
    try {
      final sanitizedQuery = _validateAndSanitizeQuery(query);
      final validLimit = _validateLimit(limit);

      AppLogger.info(
        'B\u00fasqueda de rodadas: "$sanitizedQuery" (limit: $validLimit)',
        tag: 'SearchDatasource',
      );

      final snap = await _firestore
          .collection('rides')
          .where('title', isGreaterThanOrEqualTo: sanitizedQuery)
          .where('title', isLessThanOrEqualTo: '$sanitizedQuery\uf8ff')
          .limit(validLimit)
          .get();

      AppLogger.debug(
        'Se encontraron ${snap.docs.length} rodadas',
        tag: 'SearchDatasource',
      );

      return snap.docs.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          name: data['title'] ?? '',
          photoUrl: null,
          subtitle: data['city'] ?? '',
          type: SearchResultType.ride,
        );
      }).toList();
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validaci\u00f3n fallida en b\u00fasqueda: ${e.message}',
        tag: 'SearchDatasource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error buscando rodadas: $e',
        tag: 'SearchDatasource',
        error: e,
      );
      return [];
    }
  }
}
