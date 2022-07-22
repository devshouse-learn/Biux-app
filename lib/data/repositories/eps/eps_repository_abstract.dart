import 'package:biux/data/models/eps.dart';

abstract class EpsRepositoryAbstract {
  Future<List<Eps>> getAll();
}
