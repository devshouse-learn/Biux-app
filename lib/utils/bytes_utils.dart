import 'dart:math';

import 'package:biux/config/strings.dart';

class BytesExtension {
  String getBytes(int bytes) {
    if (bytes <= 0) return AppStrings.zeroBytes;
    const suffixes = [
      AppStrings.bytes,
      AppStrings.kiloBytes,
      AppStrings.megaBytes,
      AppStrings.gigaBytes,
      AppStrings.teraBytes
    ];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(0) + suffixes[i]);
  }
}
