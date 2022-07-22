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

  BiuxUser({
    this.id,
    this.names,
    this.surnames,
    this.userName,
    this.whatsapp,
    this.cityId,
    this.gender,
    this.email,
    this.dateBirth,
    this.facebook,
    this.photo,
    this.token,
    this.cellphone,
    this.modality,
    this.password,
    this.profileCover,
    this.followerS,
    this.groupId,
    this.instagram,
    this.premium,
    this.followers,
    this.following,
    this.situationAccident,
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
      situationAccident: SituationAccident.fromJsonMap(json["situationAccident"])

    );
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
