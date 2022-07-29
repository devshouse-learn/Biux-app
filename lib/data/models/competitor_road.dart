class CompetitorRoad {
  String userId;
  CompetitorRoad({
    this.userId = '',
  });

  factory CompetitorRoad.fromJson({required Map json}) => CompetitorRoad(
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
      };
}
