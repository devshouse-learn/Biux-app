import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/accidents/data/models/situation_accident.dart';

class BiuxUser {
  final String id;
  final String fullName;
  final City cityId;
  final String userName;
  final String whatsapp;
  final String gender;
  final String email;
  final String dateBirth;
  final String facebook;
  final String photo;
  final String token;
  final String password;
  final String profileCover;
  final int followerS;
  final String groupId;
  final List modality;
  final String instagram;
  final bool premium;
  final Map followers;
  final Map following;
  final SituationAccident situationAccident;
  final String description;

  const BiuxUser({
    this.id = '',
    this.fullName = '',
    this.userName = '',
    this.whatsapp = '',
    this.cityId = const City(),
    this.gender = '',
    this.email = '',
    this.dateBirth = '',
    this.facebook = '',
    this.photo = '', // Removida URL por defecto
    this.token = '',
    this.modality = const [],
    this.password = '',
    this.profileCover = '', // Removida URL por defecto
    this.followerS = 0,
    this.groupId = '',
    this.instagram = '',
    this.premium = false,
    this.followers = const {},
    this.following = const {},
    this.situationAccident = const SituationAccident(),
    this.description = '',
  });

  factory BiuxUser.fromJsonMap(Map json) {
    // Validar que followerS no sea negativo
    int followerSCount = json["followerS"] ?? 0;
    if (followerSCount < 0) {
      print(
        '🚨 ADVERTENCIA: followerS negativo detectado! Valor: $followerSCount, fijando a 0',
      );
      followerSCount = 0;
    }

    return BiuxUser(
      id: json["id"] ?? '',
      fullName:
          json["fullName"] ??
          json["name"] ??
          '', // Intentar primero fullName, luego name
      whatsapp: json["whatsapp"] ?? '',
      userName: json["username"] ?? json["userName"] ?? '',
      gender: json["gender"] ?? '',
      cityId: _parseCityId(json["cityId"]),
      token: json['token'] ?? '',
      email: json["email"] ?? '',
      dateBirth: json[" dateBirth"] ?? '',
      facebook: json["facebook"] ?? '',
      photo:
          json["photoUrl"] ??
          json["photo"] ??
          '', // Intentar primero photoUrl, luego photo
      password: json["password"] ?? '',
      profileCover: json["profileCover"] ?? '', // Removida URL por defecto
      followerS: followerSCount,
      instagram: json["instagram"] ?? '',
      premium: json["premium"] ?? false,
      followers: json["followers"] ?? {},
      following: json["following"] ?? {},
      groupId: json["groupId"] ?? '',
      modality: json["modality"] ?? [],
      situationAccident: _parseSituationAccident(json["situationAccident"]),
      description: json["description"] ?? '',
    );
  }
  factory BiuxUser.fromMapStory(Map json) {
    return BiuxUser(
      id: json["id"],
      fullName:
          json["fullName"] ??
          json["name"] ??
          '', // Intentar primero fullName, luego name
      userName: json["username"] ?? json["userName"] ?? '',
      photo:
          json["photoUrl"] ??
          json["photo"] ??
          '', // Intentar primero photoUrl, luego photo
    );
  }

  factory BiuxUser.fromMapRoad(Map json) {
    return BiuxUser(id: json["id"], fullName: json["fullName"]);
  }

  Map<String, dynamic> toJson() {
    var userJson = {
      "id": id,
      "fullName": fullName,
      "whatsapp": whatsapp,
      "gender": gender,
      "userName": userName,
      "cityId": cityId.toJson(),
      "email": email,
      "dateBirth": dateBirth,
      "facebook": facebook,
      "photo": photo,
      "token": token,
      "modality": modality,
      "premium": premium,
      "password": password,
      "profileCover": profileCover,
      "followerS": followerS,
      "instagram": instagram,
      "followers": followers,
      "following": following,
      "groupId": groupId,
      'situationAccident': situationAccident.toJson(),
      "description": description,
    };

    var cleanUser = <String, dynamic>{};
    userJson.forEach((key, value) {
      cleanUser.putIfAbsent(key, () => value);
    });
    return cleanUser;
  }

  Map<String, dynamic> toMapStory() => {
    "id": id,
    'fullName': fullName,
    'name': fullName, // Agregar ambos campos para compatibilidad
    "userName": userName,
    "photo": photo,
  };

  Map<String, dynamic> toMapRoad() => {"id": id, 'fullName': fullName};

  // Método helper para parsear cityId que puede venir en diferentes formatos
  static City _parseCityId(dynamic cityData) {
    try {
      if (cityData == null) {
        return const City();
      }

      if (cityData is City) {
        return cityData;
      } else if (cityData is Map) {
        return City.fromJson(json: cityData.cast<String, dynamic>());
      } else if (cityData is String) {
        return const City();
      } else {
        return const City();
      }
    } catch (e) {
      return const City();
    }
  }

  // Método helper para parsear situationAccident
  static SituationAccident _parseSituationAccident(dynamic accidentData) {
    try {
      if (accidentData == null) {
        return const SituationAccident();
      }

      if (accidentData is SituationAccident) {
        return accidentData;
      } else if (accidentData is Map) {
        return SituationAccident.fromJsonMap(accidentData);
      } else {
        return const SituationAccident();
      }
    } catch (e) {
      return const SituationAccident();
    }
  }
}
