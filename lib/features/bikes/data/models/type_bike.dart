class TypeBike {
  int? id;
  String? type;

  TypeBike({this.id, this.type});

  factory TypeBike.fromJsonMap(Map json) {
    return TypeBike(
      id: json["id"] != null ? json["id"] : null,
      type: json["type"] != null ? json["type"] : null,
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "type": type};
}
