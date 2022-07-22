import 'package:biux/data/models/situation_accident.dart';

abstract class AccidentRepositoryAbstract {
  Future<List<SituationAccident>> getListAccident();
  Future getAccident();
  Future sendDatesAccident(String id, SituationAccident situationAccident);
  Future sendDatesEps(String eps);
}
