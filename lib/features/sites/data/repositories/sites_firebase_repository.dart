import 'package:biux/features/sites/data/models/sites.dart';
import 'package:biux/features/sites/domain/repositories/sites_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SitesFirebaseRepository extends SitesRepositoryAbstract {
  static final collection = 'sites';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<Sites>> getSites() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => Sites.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  Future<bool> createSites(Sites sites) async {
    try {
      await firestore.collection(collection).add(
            sites.toJson(),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Sites>> getSitesFilterByTypeSites() async {
    try {
      final result = await firestore
          .collection(collection)
          .where('typesSites.type', isEqualTo: 'Negocio')
          .get();
      return result.docs
          .map(
            (e) => Sites.fromJson(
              json: e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }
}
