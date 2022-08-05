
class Group {
  String id;
  String name;
  bool active;
  int numberMembers;
  int numberRoads;
  String logo;
  String logoADM;
  String profileCoverADM;
  String profileCover;
  String description;
  List modality;
  bool type;
  String cityAdmin;
  String whatsapp;
  String facebook;
  String instagram;
  String cityId;
  String adminId;

  Group({
    this.id = '',
    this.name = '',
    this.active = true,
    this.numberMembers = 0,
    this.numberRoads = 0,
    this.logo = '',
    this.logoADM = '',
    this.profileCoverADM = '',
    this.profileCover = '',
    this.description = '',
    this.modality = const [],
    this.type = true,
    this.cityId = '',
    this.cityAdmin = '',
    this.adminId = '',
    this.facebook = '',
    this.instagram = '',
    this.whatsapp = '',
  });

  factory Group.fromJson({required Map json}) => Group(
        id: json["id"],
        name: json["name"],
        active: json["active"],
        adminId: json["adminId"],
        cityAdmin: json["cityAdmin"],
        cityId: json["cityId"],
        description: json["description"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        logo: json["logo"] ??
            "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
        logoADM: json["logoADM"],
        modality: json["modality"],
        numberMembers: json["numberMembers"],
        numberRoads: json["numberRoads"],
        profileCover: json["profileCover"] ??
            "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
        profileCoverADM: json["profileCoverADM"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "numberMembers": numberMembers,
        "numberRoads": numberRoads,
        "active": active,
        "logo": logo,
        "logoADM": logoADM,
        "profileCoverADM": profileCoverADM,
        "adminId": adminId,
        "profileCover": profileCover,
        "description": description,
        "modality": modality,
        "type": type,
        "cityAdmin": cityAdmin,
        "whatsapp": whatsapp,
        "cityId": cityId,
        "facebook": facebook,
        "instagram": instagram,
      };
}
