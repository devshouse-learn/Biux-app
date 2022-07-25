import 'package:biux/data/models/types_sites.dart';

class Sites {
  String id;
  String name;
  String icon;
  String telephone;
  String whatsapp;
  String facebook;
  String instagram;
  String category;
  String description;
  String email;
  String schedule;
  String cityId;
  TypesSites typesSites;
  String profileCover;
  String direction;
  double latitude;
  double longitude;

  Sites({
    required this.id,
    this.name = '',
    this.icon = '',
    this.telephone = '',
    this.whatsapp = '',
    this.facebook = '',
    this.instagram = '',
    this.cityId = '',
    this.category = '',
    this.description = '',
    this.email = '',
    this.profileCover = '',
    required this.typesSites,
    this.schedule = '',
    this.direction = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Sites.fromJson({required Map json}) => Sites(
        id: json["id"],
        typesSites: TypesSites.fromJsonMap(json: json["typesSites"]),
        name: json["name"],
        icon: json["icon"],
        profileCover: json["profileCover"],
        telephone: json["telephone"],
        category: json["category"],
        cityId: json["city"],
        description: json["description"],
        direction: json["direction"],
        email: json["email"],
        whatsapp: json["whatsapp"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        latitude: json["latitude"],
        longitude: json["latitude"],
        schedule: json["schedule"],
      );

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
        "schedule": schedule,
        "city": cityId,
        "direction": direction,
        "email": email,
        "latitude": latitude,
        "longitude": longitude,
        "typesSites": typesSites.toJson(),
      };
}
