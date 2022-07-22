class Membership {
int? id;
String? name;

Membership({
  this.id,
  this.name,
});

Membership.fromJsonMap(Map json){
  this.id = json["id"];
  this.name = json["name"];
}

Map<String, dynamic> toJson() => {
  "id": id,
  "name": name,
};
}