import 'package:biux/data/models/sites.dart';
abstract class SitesRepositoryAbstract {
  Future<List<Sites>> getSites();
  Future<List<Sites>> getSitesFilterByTypeSites();
}
