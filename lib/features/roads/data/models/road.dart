import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/users/data/models/user.dart';

class Road {
  String id;
  int numberParticipants;
  String name;
  String dateTime;
  String pointmeeting;
  List modality;
  String image;
  String description;
  double routeLevel;
  int numberLikes;
  double distance;
  String cityId;
  bool status;
  bool public;
  Group group;
  List<BiuxUser> competitorRoad;
  String geocalizationPoint;

  Road({
    this.id = '',
    this.numberParticipants = 0,
    this.name = '',
    this.dateTime = '',
    this.pointmeeting = '',
    this.modality = const [],
    this.routeLevel = 0,
    this.image = '',
    this.description = '',
    this.distance = 0.0,
    this.cityId = '',
    this.status = false,
    this.numberLikes = 0,
    this.public = false,
    required this.group,
    this.competitorRoad = const [],
    this.geocalizationPoint = '',
  });

  factory Road.fromJson({required Map json, required String id}) => Road(
    id: id,
    numberParticipants: json["numberParticipants"],
    cityId: json["cityId"],
    dateTime: json["dateTime"],
    description: json["description"],
    distance: json["distance"],
    name: json["name"],
    image: json["image"],
    modality: json["modality"],
    numberLikes: json["numberLikes"],
    pointmeeting: json["pointmeeting"],
    routeLevel: double.parse(json["routeLevel"]),
    status: json["status"],
    public: json["public"],
    group: Group.fromJsonRoad(json: json["group"]),
    competitorRoad: (json['competitorRoad'] as List<dynamic>)
        .map((e) => BiuxUser.fromMapRoad(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "numberParticipants": numberParticipants,
    "name": name,
    "dateTime": dateTime,
    "pointmeeting": pointmeeting,
    "modality": modality,
    "image": image,
    "description": description,
    "numberLikes": numberLikes,
    "routeLevel": routeLevel.toString(),
    "distance": distance,
    "cityId": cityId,
    "status": status,
    "public": public,
    "group": group.toJsonRoad(),
    "competitorRoad": competitorRoad.map((e) => e.toMapRoad()).toList(),
  };
}
