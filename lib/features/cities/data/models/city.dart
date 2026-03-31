class City {
  final String id;
  final String name;
  final String state;
  final String country;
  final String latitude;
  final String longitude;

  const City({
    this.id = "",
    this.name = "",
    this.state = "",
    this.country = "",
    this.latitude = "",
    this.longitude = "",
  });

  factory City.fromJson({required Map json}) => City(
    id: json["id"],
    name: json["name"],
    state: json["state"],
    country: json["country"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  factory City.fromMapUser(Map json) {
    return City(id: json["id"], name: json["name"]);
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "state": state,
    "country": country,
    "latitude": latitude,
    "longitude": longitude,
  };

  Map<String, dynamic> toMapUser() => {"id": id, "name": name};
}
