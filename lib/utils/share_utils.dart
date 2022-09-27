import 'package:biux/config/strings.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_share/flutter_share.dart';

class ShareUtils {
  Future<void> shareFile({
    required String title,
    required String text,
    required String filePath,
  }) async {
    final imagePath = await urlToFile(filePath);
    await FlutterShare.shareFile(
      title: title,
      text: text,
      filePath: imagePath.path,
    );
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(
      ('$tempPath' + '${AppStrings.storyText}' + (rng.nextInt(100)).toString()) + '.jpg',
    );
    var url = Uri.parse(imageUrl);
    http.Response response = await http.get(
      url,
    );
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
