import 'package:biux/data/models/advertising.dart';

abstract class AdvertisingRepositoryAbstract {
  Future<Advertising> getAdvertising();
}
