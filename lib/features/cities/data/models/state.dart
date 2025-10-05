import 'package:biux/features/cities/data/models/country.dart';

class StateCountry {
  int? id;
  String? name;
  Country? country;

  StateCountry({
    this.id,
    this.name,
    this.country,
  });

  StateCountry.fromJsonMap(Map json) {
    this.id = json["id"];
    this.name = json["name"];
    this.country = Country.fromJsonMap(
      json["country"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
      };
}
