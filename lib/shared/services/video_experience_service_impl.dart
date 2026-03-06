import 'dart:async';
import 'dart:io';

class VideoExperienceServiceImpl {
  /// IMPLEMENTADO (STUB): Thumbnail placeholder.
  Future<File?> generateThumbnail(File videoFile) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return null;
  }

  /// IMPLEMENTADO (STUB): Validacion de duracion.
  Future<bool> validateDuration(File videoFile, {required Duration maxDuration}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
