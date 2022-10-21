import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/situation_accident.dart';

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
    this.photo =
        'https://rubibike.com/wp-content/uploads/2020/12/la_importacia_del_equipamiento_para_el_ciclista.jpg',
    this.token = '',
    this.modality = const [],
    this.password = '',
    this.profileCover =
        'https://rubibike.com/wp-content/uploads/2020/12/la_importacia_del_equipamiento_para_el_ciclista.jpg',
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
    return BiuxUser(
      id: json["id"] ?? '',
      fullName: json["fullName"] ?? '',
      whatsapp: json["whatsapp"] ?? '',
      userName: json["userName"] ?? '',
      gender: json["gender"] ?? '',
      cityId: City.fromJson(json: json["cityId"] ?? City()),
      token: json['token'] ?? '',
      email: json["email"] ?? '',
      dateBirth: json[" dateBirth"] ?? '',
      facebook: json["facebook"] ?? '',
      photo: json["photo"] ??
          "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
      password: json["password"] ?? '',
      profileCover: json["profileCover"] ??
          "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
      followerS: json["followerS"] ?? 0,
      instagram: json["instagram"] ?? '',
      premium: json["premium"] ?? false,
      followers: json["followers"] ?? {},
      following: json["following"] ?? {},
      groupId: json["groupId"] ?? '',
      modality: json["modality"],
      situationAccident: SituationAccident.fromJsonMap(
        json["situationAccident"],
      ),
      description: json["description"] ?? '',
    );
  }
  factory BiuxUser.fromMapStory(Map json) {
    return BiuxUser(
      id: json["id"],
      fullName: json["fullName"],
      userName: json["userName"],
      photo: json["photo"] ??
          "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
    );
  }

  factory BiuxUser.fromMapRoad(Map json) {
    return BiuxUser(
      id: json["id"],
      fullName: json["fullName"],
    );
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
    userJson.forEach(
      (key, value) {
        if (value != null) {
          cleanUser.putIfAbsent(key, () => value);
        }
      },
    );
    return cleanUser;
  }

  Map<String, dynamic> toMapStory() => {
        "id": id,
        'fullName': fullName,
        "userName": userName,
        "photo": photo,
      };

  Map<String, dynamic> toMapRoad() => {
        "id": id,
        'fullName': fullName,
      };
}
