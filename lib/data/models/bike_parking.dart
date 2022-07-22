class BikeParking {
  int? id;
  String? name;
  String? icon;
  String? telephone;
  String? whatsapp;
  String? facebook;
  String? instagram;
  String? category;
  String? description;
  String? city;
  String? profileCover;
  String? direction;
  double? latitude;
  double? longitude;

  BikeParking({
    this.id,
    this.name,
    this.icon,
    this.telephone,
    this.whatsapp,
    this.facebook,
    this.instagram,
    this.city,
    this.category,
    this.description,
    this.profileCover,
    this.direction,
    this.latitude,
    this.longitude,
  });

  BikeParking.fromJson(Map json) {
    this.id = json["id"];
    this.name = json["name"];
    this.icon = json["icon"];
    this.profileCover = json["profileCover"];
    this.telephone = json["telephone"];
    this.whatsapp = json["whatsapp"];
    this.facebook = json["facebook"];
    this.instagram = json["instagram"];
    this.category = json["category"];
    this.description = json["description"];
    this.city = json["city"];
    this.direction = json["direction"];
    this.latitude = json["latitude"];
    this.longitude = json["longitude"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "category": category,
        "description": description,
        "profileCover": profileCover,
        "telephone": telephone,
        "whatsapp": whatsapp,
        "facebook": facebook,
        "instagram": instagram,
        "city": city,
        "direction": direction,
        "latitude": latitude,
        "longitude": longitude,
      };
}
