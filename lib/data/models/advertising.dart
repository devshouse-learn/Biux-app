class Advertising {
  String docId;
  String photoAd;
  String description;
  double costOpen;
  double costWatch;
  double money;
  String title;
  String url;
  String textButton;

  Advertising({
    required this.docId,
    this.costOpen = 0,
    this.costWatch = 0,
    this.description = '',
    this.money = 0,
    this.photoAd = '',
    this.url = '',
    this.textButton = '',
    this.title = '',
  });

  factory Advertising.fromJsonMap({required Map json, required String docId}) =>
      Advertising(
        docId: docId,
        costOpen: json["costOpen"] ?? 0.0,
        costWatch: json["costWatch"] ?? 0.0,
        description: json["description"] ?? '',
        money: json["money"] ?? 0.0,
        photoAd: json["photoAd"] ?? '',
        url: json["url"] ?? '',
        textButton: json["textButton"] ?? '',
        title: json["title"] ?? '',
      );
}
