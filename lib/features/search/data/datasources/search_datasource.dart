import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/search/domain/entities/search_result_entity.dart';

/// Datasource de búsqueda que consulta Firestore.
class SearchDatasource {
  final FirebaseFirestore _firestore;

  SearchDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SearchResult>> searchUsers(String query, {int limit = 15}) async {
    final snap = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

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
  }

  Future<List<SearchResult>> searchGroups(
    String query, {
    int limit = 15,
  }) async {
    final snap = await _firestore
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

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
  }

  Future<List<SearchResult>> searchRides(String query, {int limit = 15}) async {
    final snap = await _firestore
        .collection('rides')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

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
  }
}
