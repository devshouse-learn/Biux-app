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
  String cityAdmin;
  String whatsapp;
  String facebook;
  String instagram;
  String cityId;
  String adminId;
  bool public;

  Group({
    this.id = '',
    this.name = '',
    this.active = true,
    this.numberMembers = 0,
    this.numberRoads = 0,
    this.logo =
        'https://play-lh.googleusercontent.com/wyyEURZBz5PI4qbTeJTelVlQrbXj5RQVu8ZCG-DldcOaZLDcULUq71palN3SWny2SrdK',
    this.logoADM = '',
    this.profileCoverADM = '',
    this.profileCover =
        'https://play-lh.googleusercontent.com/wyyEURZBz5PI4qbTeJTelVlQrbXj5RQVu8ZCG-DldcOaZLDcULUq71palN3SWny2SrdK',
    this.description = '',
    this.modality = const [],
    this.cityId = '',
    this.cityAdmin = '',
    this.adminId = '',
    this.facebook = '',
    this.instagram = '',
    this.whatsapp = '',
    this.public = false,
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
        whatsapp: json["whatsapp"],
        public: json["public"],
      );

  factory Group.fromJsonRoad({required Map json}) => Group(
        id: json["id"],
        adminId: json["adminId"],
        logo: json["logo"] ??
            "https://lh3.googleusercontent.com/wq0_KD2KZpzof7IR9sEaYTA5_PRE_aeJS0eKdrcmM7o5elnQ5keCxo29IG-DuEG4Rw",
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
        "cityAdmin": cityAdmin,
        "whatsapp": whatsapp,
        "cityId": cityId,
        "facebook": facebook,
        "instagram": instagram,
        "public": public
      };

  Map<String, dynamic> toJsonRoad() => {
        "id": id,
        "logo": logo,
        "adminId": adminId,
      };
}
