import 'package:biux/data/models/sites.dart';
import 'package:biux/data/models/types_sites.dart';

abstract class SitesRepositoryAbstract {
  Future<List<Sites>> getSites();
  Future<List<Sites>> getSitesFilter();
  Future<TypesSites> getTypesSites();
}
