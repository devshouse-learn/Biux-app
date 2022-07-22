class TypesSites {
  int? id;
  String? type;

  TypesSites({
    this.id,
    this.type,
  });

  TypesSites.fromJsonMap(Map json) {
    this.id = json["id"];
    this.type = json["type"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
      };
}
