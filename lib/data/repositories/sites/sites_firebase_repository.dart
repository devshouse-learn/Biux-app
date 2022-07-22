import 'package:biux/data/models/types_sites.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/data/repositories/sites/sites_repository_abstract.dart';
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
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<Sites>> getSitesFilter() async {
    try {
      final result = await firestore
          .collection(collection)
          .where('typesSites.',
              isEqualTo: TypesSites(
                type: 'Negocio',
              ))
          .get();
      return result.docs
          .map(
            (e) => Sites.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<TypesSites> getTypesSites() {
    // TODO: implement getTypesSites
    throw UnimplementedError();
  }
}
