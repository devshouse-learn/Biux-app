class TypesSites {
  String id;
  String type;

  TypesSites({required this.id, this.type = ''});

  factory TypesSites.fromJsonMap({required Map json}) =>
      TypesSites(id: json["id"], type: json["type"]);

  Map<String, dynamic> toJson() => {"id": id, "type": type};
}
