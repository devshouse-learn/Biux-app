class Membership {
  int? id;
  String? name;
  String? description;
  double? price;
  String? duration;
  bool? active;

  Membership({
    this.id,
    this.name,
    this.description,
    this.price,
    this.duration,
    this.active,
  });

  Membership.fromJsonMap(Map json) {
    this.id = json["id"];
    this.name = json["name"];
    this.description = json["description"];
    this.price = json["price"]?.toDouble();
    this.duration = json["duration"];
    this.active = json["active"];
  }

  Map toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "duration": duration,
      "active": active,
    };
  }
}