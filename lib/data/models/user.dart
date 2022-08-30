import 'package:biux/data/models/situation_accident.dart';

class BiuxUser {
  String? id;
  String? names;
  String? surnames;
  String? cityId;
  String? userName;
  String? whatsapp;
  String? gender;
  String? email;
  String? dateBirth;
  String? facebook;
  String? photo;
  String? token;
  String? cellphone;
  String? password;
  String? profileCover;
  int? followerS;
  String? groupId;
  List? modality;
  String? instagram;
  bool? premium;
  final Map? followers;
  final Map? following;
  SituationAccident? situationAccident;
  String? description;

  BiuxUser({
    this.id = '',
    this.names = '',
    this.surnames = '',
    this.userName = '',
    this.whatsapp = '',
    this.cityId = '',
    this.gender = '',
    this.email = '',
    this.dateBirth = '',
    this.facebook = '',
    this.photo =
        'https://rubibike.com/wp-content/uploads/2020/12/la_importacia_del_equipamiento_para_el_ciclista.jpg',
    this.token = '',
    this.cellphone = '',
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
    this.situationAccident,
    this.description = '',
  });

  factory BiuxUser.fromJsonMap(Map json) {
    return BiuxUser(
        id: json["id"],
        names: json["names"],
        surnames: json["surnames"],
        whatsapp: json["whatsapp"],
        userName: json["userName"],
        gender: json["gender"],
        cityId: json["cityId"],
        token: json['token'],
        email: json["email"],
        dateBirth: json[" dateBirth"],
        facebook: json["facebook"],
        photo: json["photo"] ??
            "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
        cellphone: json["cellphone"],
        password: json["password"],
        profileCover: json["profileCover"] ??
            "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
        followerS: json["followerS"],
        instagram: json["instagram"],
        premium: json["premium"],
        followers: json["followers"],
        following: json["following"],
        groupId: json["groupId"],
        situationAccident:
            SituationAccident.fromJsonMap(json["situationAccident"]),
            description: json["description"],);
        
  }
  Map<String, dynamic> toJson() {
    var userJson = {
      "id": id,
      "names": names,
      "surnames": surnames,
      "whatsapp": whatsapp,
      "gender": gender,
      "userName": userName,
      "cityId": cityId,
      "email": email,
      "dateBirth": dateBirth,
      "facebook": facebook,
      "photo": photo,
      "token": token,
      "cellphone": cellphone,
      "modality": modality,
      "premium": premium,
      "password": password,
      "profileCover": profileCover,
      "followerS": followerS,
      "instagram": instagram,
      "followers": followers,
      "following": following,
      "groupId": groupId,
      'situationAccident': situationAccident?.toJson(),
      "description": description,
    };

    var cleanUser = <String, dynamic>{};
    userJson.forEach((key, value) {
      if (value != null) {
        cleanUser.putIfAbsent(key, () => value);
      }
    });
    return cleanUser;
  }
}
