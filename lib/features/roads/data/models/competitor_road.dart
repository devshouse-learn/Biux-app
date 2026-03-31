class CompetitorRoad {
  String id;
  String userId;

  CompetitorRoad({this.id = '', this.userId = ''});

  factory CompetitorRoad.fromJsonMap({required Map json}) =>
      CompetitorRoad(id: json["id"], userId: json["userId"]);

  Map<String, dynamic> toJson() => {"id": id, "userId": userId};
}
