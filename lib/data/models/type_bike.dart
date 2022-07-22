
class TypeBike {
  int? id;
  String? type;

  TypeBike({
    this.id,
    this.type,
  });

  factory TypeBike.fromJsonMap(Map json) {
    var tipobicicletaVacia = TypeBike();
    if (json != null) {
      return TypeBike(
        id: json["id"] != null ? json["id"] : null,
        type: json["tipo"] != null ? json["type"] : null,
      );
    } else {
      return tipobicicletaVacia;
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
      };
}
