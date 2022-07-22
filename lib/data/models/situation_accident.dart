class SituationAccident {
  String? allergies;
  String? contactEmergency;
  String? nameEps;
  int? id;
  String? medicines;
  String? rh;

  SituationAccident({
    this.allergies,
    this.contactEmergency,
    this.nameEps,
    this.id,
    this.medicines,
    this.rh,
  });

  SituationAccident.fromJsonMap(Map json) {
    this.allergies = json["allergies"];
    this.contactEmergency = json["contactEmergency"];
    this.nameEps = json["epsId"];
    this.id = json["id"];
    this.medicines = json["medicines"];
    this.rh = json["rh"];
  }

  Map<String, dynamic> toJson() => {
        "allergies": allergies,
        "contactEmergency": contactEmergency,
        "nameEps": nameEps,
        "id": id,
        "medicines": medicines,
        "rh": rh,
      };
}
