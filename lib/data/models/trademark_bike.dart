class TrademarkBike {
  int? id;
  String? trademark;

  TrademarkBike({
    this.id,
    this.trademark,
  });

  factory TrademarkBike.fromJsonMap(Map json) {
    return TrademarkBike(
      id: json["id"],
      trademark: json["trademark"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "trademark": trademark,
      };
}
