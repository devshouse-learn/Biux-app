import 'dart:io';
import 'dart:math';

import 'package:biux/config/strings.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  Future<void> shareFile({
    required String title,
    required String text,
    required String filePath,
  }) async {
    final imagePath = await XFile(filePath);
    SharePlus.instance.share(ShareParams(
      title: title,
      text: text,
      files: [imagePath],
    ));
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(
      ('$tempPath' +
              '${AppStrings.storyText}' +
              (rng.nextInt(100)).toString()) +
          '.jpg',
    );
    var url = Uri.parse(imageUrl);
    http.Response response = await http.get(
      url,
    );
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
