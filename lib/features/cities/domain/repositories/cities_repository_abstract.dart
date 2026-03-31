import 'package:biux/features/cities/data/models/city.dart';

abstract class CitiesRepositoryAbstract {
  Future<City> getCityId(String cityName);
  Future<List<City>> getCities();
  Future<City> getSpecifiCities(int id);
}
