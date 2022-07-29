import 'package:biux/data/models/situation_accident.dart';

abstract class AccidentRepositoryAbstract {
  Future<List<SituationAccident>> getListAccident();
  Future getAccident();
  Future createDatesAccident(String id, SituationAccident situationAccident);
  Future createDatesEps(String eps);
}
