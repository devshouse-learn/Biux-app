

import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/user.dart';

class Group {
  String? id;
  String? name;
  bool? active;
  String? namesAdmin;
  String? surnamesAdmin;
  int? numberMembers;
  int? numberRoads;
  String? logo;
  String? logoADM;
  String? profileCoverADM;
  String? profileCover;
  String? description;
  List? modality;
  BiuxUser? admin;
  bool? type;
  City? city;
  String? cityAdmin;
  String? whatsapp;
  String? facebook;
  String? instagram;
  String? cityId;
  String? adminId;

  Group({
    this.id,
    this.name,
    this.active,
    this.namesAdmin,
    this.surnamesAdmin,
    this.numberMembers,
    this.numberRoads,
    this.logo,
    this.logoADM,
    this.profileCoverADM,
    this.profileCover,
    this.description,
    this.modality,
    this.type,
    this.cityId,
    this.city,
    this.cityAdmin,
    this.admin,
    this.adminId,
    this.whatsapp,
    // Text content,
    this.facebook,
    this.instagram,
  });

  Group.fromJson(Map json) {
    if (json != null) {
      this.id = json["id"];
      this.name = json["name"];
      this.numberMembers = json["numberMembers"];
      this.active = json["active"];
      this.numberRoads = json["numberRoads"];
      this.logo = json["logo"] ?? "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw";
      this.profileCover = json["profileCover"] ?? "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw";
      // this.logoADM = json["administrador"]["foto"];
      // this.portadaADM = json["administrador"]["portada"];
      this.description = json["description"];
      this.modality = json["modality"];
      this.admin = BiuxUser.fromJsonMap(json["admin"] ?? Map());
      this.type = json["type"];
      this.adminId = json["adminId"];
      this.cityId = json["cityId"];
      this.city = City.fromJsonMap(json["city"] ?? Map);
      // this.ciudadAdmin =
      //     json["administrador"]["ciudad"]["departamento"]["nombre"];
      this.whatsapp = json["whatsapp"];
      this.facebook = json["facebook"];
      this.instagram = json["instagram"];
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "namesAdmin": namesAdmin,
        "surnamesAdmin": surnamesAdmin,
        "numberMembers": numberMembers,
        "numberRoads": numberRoads,
        "active": active,
        "logo": logo,
        "logoADM": logoADM,
        "profileCoverADM": profileCoverADM,
        "adminId": adminId,
        "admin": admin,
        "profileCover": profileCover,
        "description": description,
        "modality": modality,
        "type": type,
        "city": city,
        "cityAdmin": cityAdmin,
        "whatsapp": whatsapp,
        "cityId": cityId,
        "facebook": facebook,
        "instagram": instagram,
      };
}
