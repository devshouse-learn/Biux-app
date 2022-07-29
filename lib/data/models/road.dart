class Road {
  String id;
  int numberParticipants;
  String name;
  String dateTime;
  String pointmeeting;
  String route;
  List modality;
  String image;
  String description;
  int routeLevel;
  int numberLikes;
  double distance;
  String groupId;
  String cityId;
  bool type;
  bool status;

  Road({
    required this.id,
    this.numberParticipants = 0,
    this.name = '',
    this.dateTime = '',
    this.pointmeeting = '',
    this.route = '',
    this.modality = const [],
    this.routeLevel = 0,
    this.image = '',
    this.description = '',
    this.distance = 0.0,
    this.groupId = '',
    this.cityId = '',
    this.type = false,
    this.status = false,
    this.numberLikes = 0,
  });

  factory Road.fromJson({required Map json}) => Road(
        id: json["id"],
        numberParticipants: json["numberParticipants"],
        cityId: json["cityId"],
        dateTime: json["dateTime"],
        description: json["description"],
        distance: json["distance"],
        name: json["name"],
        groupId: json["groupId"],
        image: json["image"],
        modality: json["modality"],
        numberLikes: json["numberLikes"],
        pointmeeting: json["pointmeeting"],
        route: json["route"],
        routeLevel: json["routeLevel"],
        status: json["status"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "numberParticipants": numberParticipants,
        "name": name,
        "dateTime": dateTime,
        "pointmeeting": pointmeeting,
        "route": route,
        "modality": modality,
        "image": image,
        "description": description,
        "numberLikes": numberLikes,
        "routeLevel": routeLevel,
        "distance": distance,
        "groupId": groupId,
        "cityId": cityId,
        "type": type,
        "status": status,
      };
}
