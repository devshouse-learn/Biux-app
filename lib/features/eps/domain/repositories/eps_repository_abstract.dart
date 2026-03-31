import 'package:biux/features/eps/data/models/eps.dart';

abstract class EpsRepositoryAbstract {
  Future<List<Eps>> getAll();
}
