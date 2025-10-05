class SituationAccident {
  final String? allergies;
  final String? contactEmergency;
  final String? nameEps;
  final String? id;
  final String? medicines;
  final String? rh;

  const SituationAccident({
    this.allergies,
    this.contactEmergency,
    this.nameEps,
    this.id,
    this.medicines,
    this.rh,
  });

  factory SituationAccident.fromJsonMap(Map json) {
    return SituationAccident(
      allergies: json["allergies"] ?? '',
      contactEmergency: json["contactEmergency"] ?? '',
      id: json["id"] ?? '',
      medicines: json["medicines"] ?? '',
      nameEps: json["epsId"] ?? '',
      rh: json["rh"] ?? '',
    );
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
