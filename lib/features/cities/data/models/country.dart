class Country {
int? id;
String? name;

Country({
  this.id,
  this.name,
});

Country.fromJsonMap(Map json){
  this.id = json["id"];
  this.name = json["name"];
}

Map<String, dynamic> toJson() => {
  "id": id,
  "name": name,
};
}