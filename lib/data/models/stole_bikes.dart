
import 'package:biux/data/models/bike.dart';

class StoleBikes {
  String? bikeId;
  String? description;
  String? direction;
  String? dateCreate;
  String? datetimeStole;
  String? id;
 // Bike? bike;

  StoleBikes({
    this.bikeId,
    this.description,
    this.direction,
    this.dateCreate,
    this.datetimeStole,
    this.id,
   // this.bike,
  });

  factory StoleBikes.fromjson(Map json) {
    return StoleBikes(
        bikeId: json["bikeId"],
        description: json["description"],
        direction: json["direction"],
        dateCreate: json["dateCreate"],
        datetimeStole: json["datetimeStole"],
        id: json["id"],
       // bike: Bike.fromjson(json["bike"]),
      );
  }

  Map<String, dynamic> toJson() => {
        "bikeId": bikeId,
        "description": description,
        "direction": direction,
        "dateCreate": dateCreate,
        "datetimeStole": datetimeStole,
        "id": id,
       // "bike": bike!.toJson(),
      };
}
