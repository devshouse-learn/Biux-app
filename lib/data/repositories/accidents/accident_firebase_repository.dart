import 'package:biux/data/models/situation_accident.dart';
import 'package:biux/data/repositories/accidents/accident_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/bike.dart';

class AccidentFirebaseRepository extends AccidentRepositoryAbstract {
  static final collection = 'users';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<SituationAccident>> getListAccident() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => SituationAccident.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future getAccident() async {
    try {
      final result = await firestore.collection(collection).get();
      return SituationAccident.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return SituationAccident();
    }
  }

  @override
  Future sendDatesAccident(
      String id, SituationAccident situationAccident) async {
    try {
      await firestore.collection(collection).doc("$id").update({
        'situationAccident.allergies': situationAccident.allergies,
        'situationAccident.contactEmergency': situationAccident.contactEmergency,
        // 'situationAccident.epsId': situationAccident.epsId,
        'situationAccident.id': situationAccident.id,
        'situationAccident.medicines': situationAccident.medicines,
        'situationAccident.rh': situationAccident.rh,
        // 'situationAccident.userId': situationAccident.userId
      });
    } catch (e) {}
  }

  @override
  Future sendDatesEps(String eps) async {
    try {
      await firestore.collection(collection).add({'eps': eps});
    } catch (e) {}
  }
}
