import 'package:biux/data/models/trademark_bike.dart';
import 'package:biux/data/models/type_bike.dart';
import 'package:biux/data/models/user.dart';

class Bike {
  String? measurement;
  String? storeBuy;
  String? description;
  String? dateBuy;
  String? photoBikeComplete;
  String? photoInvoice;
  String? photoFrontal;
  String? photoGroupBike;
  String? photoSerial;
  String? photoOwnershipCard;
  TrademarkBike? trademarkBike;
  String? id;
  String? numberInvoice;
  String? serial;
  int? userId;
  TypeBike? typeBike;

  Bike({
    this.measurement,
    this.storeBuy,
    this.description,
    this.dateBuy,
    this.photoBikeComplete,
    this.photoInvoice,
    this.photoFrontal,
    this.photoGroupBike,
    this.photoSerial,
    this.photoOwnershipCard,
    this.id,
    this.numberInvoice,
    this.serial,
    this.userId,
    this.trademarkBike,
    this.typeBike,
  });

  factory Bike.fromjson(Map json) {
    var bicicletaVacia = Bike();
    if (json != null) {
      Bike bicicleta = Bike(
        measurement: json["measurement"],
        storeBuy: json["storeBuy"],
        description: json["description"],
        dateBuy: json["dateBuy"],
        photoBikeComplete: json["photoBikeComplete"],
        photoInvoice: json["photoInvoice"],
        photoFrontal: json["photoFrontal"],
        photoGroupBike: json["photoGroupBike"],
        photoSerial: json["photoSerial"],
        photoOwnershipCard: json["photoOwnershipCard"],
        id: json["id"] == null ? null : json["id"],
        numberInvoice: json["numberInvoice"],
        serial: json["serial"],
        userId: json["userId"],
        trademarkBike: TrademarkBike.fromJsonMap(json["trademarkBike"]),
        typeBike: TypeBike.fromJsonMap(json["tipoBicicleta"]),
      );
      return bicicleta;
    } else {
      return bicicletaVacia;
    }
  }

  Map<String, dynamic> toJson() => {
        "measurement": measurement,
        "id": id,
        "storeBuy": storeBuy,
        "description": description,
        "dateBuy": dateBuy,
        "photoBikeComplete": photoBikeComplete,
        "photoInvoice": photoInvoice,
        "photoFrontal": photoFrontal,
        "photoGroupBike": photoGroupBike,
        "photoSerial": photoSerial,
        "photoOwnershipCard": photoOwnershipCard,
        "trademarkBike": trademarkBike!.toJson(),
        "numberInvoice": numberInvoice,
        "serial": serial,
        "typeBike": typeBike!.toJson(),
        "userId": userId,
      };
}
