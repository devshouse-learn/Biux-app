import 'dart:ffi';

class Event {
  String? images;
  DateTime? dateTime;
  List? organize;
  List? patronize;
  String? route;
  Double? kilometres;
  String? planimetry;
  String? pointMeeting;
  Double? prices;

  Event({
    this.images,
    this.dateTime,
    this.organize,
    this.patronize,
    this.route,
    this.kilometres,
    this.planimetry,
    this.pointMeeting,
    this.prices,
  });

  Event.fromJson(Map json) {
    this.images = json["images"];
    this.dateTime = DateTime.fromMicrosecondsSinceEpoch(json["dateTime"]);
    this.organize = json["organize"];
    this.patronize = json["patronize"];
    this.route = json["route"];
    this.kilometres = json["kilometres"];
    this.planimetry = json["planimetry"];
    this.pointMeeting = json["pointMeeting"];
    this.prices = json["prices"];
  }

  Map<String, dynamic> toJson() => {
        "images": images,
        "dateTime": dateTime,
        "organize": organize,
        "patronize": patronize,
        "route": route,
        "kilometres": kilometres,
        "planimetry": planimetry,
        "pointMeeting": pointMeeting,
        "prices": prices,
      };
}
