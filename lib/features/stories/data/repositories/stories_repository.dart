import 'dart:io';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoriesRepository {
  final URL_BASE = "https://biux-prod.ibacrea.com/api/v1/historias";
  final URLREACTIONSTORY =
      "https://biux-prod.ibacrea.com/api/v1/reaccionesHistoria";

  Future<List<Story>> getStories() async {
    var url = '$URL_BASE?export=true';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List storyJson = responseData["data"];
    List<Story> stories =
        storyJson.map((storyJson) => Story.fromJson(storyJson, storyJson)).toList();

    return stories;
  }

  Future<List<Story>> getStoryItem() async {
    var url = 'https://biux-prod.ibacrea.com/api/v1/historias-item?export=true';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List storyItemJson = responseData["data"];
    List<Story> storiesItem = storyItemJson
        .map((storyItemJson) => Story.fromJson(storyItemJson, storyItemJson))
        .toList();

    return storiesItem;
  }

  Future<Story?> createStoryItem(Story storyItem) async {
    try {
      var storyVoid = Story();
      var uriResponse = await http.post(
          Uri.parse("https://biux-prod.ibacrea.com/api/v1/historias-item"),
          body: jsonEncode(storyItem.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
          });
      if (uriResponse.statusCode == 200) {
      } else {
        return storyVoid;
      }
    } catch (e) {}
  }

  Future reactionStory(
    String userId,
    String storyId,
  ) async {
    var uriResponse = await http.post(Uri.parse(URLREACTIONSTORY),
        body: jsonEncode({
          "userId": userId,
          "storyId": storyId,
        }),
        headers: {
          'Content-type': 'application/json',
          // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
        });
    if (uriResponse.statusCode == 200) {
      final data = json.decode(uriResponse.body);
      // int id = datal["id"];
      return "Bien";
    } else if (uriResponse.statusCode != 200) {
      return uriResponse.reasonPhrase;
    }
  }

  Future uploadImageStory(
    int id,
    File image,
  ) async {
    Dio dio = new Dio();
    // dio.options.headers["content-Type"] = "multipart/form-data";
    // dio.options.headers["authorization"] = await LocalStorage().getToken();
    FormData formData = FormData.fromMap(
      {
        "file": await MultipartFile.fromFile(
          image.path,
        ),
      },
    );
    Response response = await dio.patch(
      'https://biux-prod.ibacrea.com/api/v1/historias-item/$id/subir-fotos',
      data: formData,
    );
  }
}
