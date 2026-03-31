class Eps {
  String id;
  String name;

  Eps({required this.id, required this.name});

  factory Eps.fromJson({required Map json, required String docId}) =>
      Eps(id: docId, name: json['name']);
}
