
class StoleBikes {
  String? bikeId;
  String? description;
  String? direction;
  String? dateCreate;
  String? datetimeStole;
  String? id;

  StoleBikes({
    this.bikeId,
    this.description,
    this.direction,
    this.dateCreate,
    this.datetimeStole,
    this.id,
  });

  factory StoleBikes.fromjson(Map json) {
    return StoleBikes(
        bikeId: json["bikeId"],
        description: json["description"],
        direction: json["direction"],
        dateCreate: json["dateCreate"],
        datetimeStole: json["datetimeStole"],
        id: json["id"],
      );
  }

  Map<String, dynamic> toJson() => {
        "bikeId": bikeId,
        "description": description,
        "direction": direction,
        "dateCreate": dateCreate,
        "datetimeStole": datetimeStole,
        "id": id,
      };
}
