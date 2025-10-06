import 'package:biux/core/config/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchSocialNetworks {
  Future<bool> launchwhatsapp(String whatsapp, String name) async {
    final result = await launch(
      AppStrings.whatsappMessage(whatsappNumber: whatsapp, name: name),
    );
    return result;
  }

  Future<bool> launchFacebook(String facebook) {
    final result = launch(facebook);
    return result;
  }

  Future<bool> launchInstagram(String instagram) {
    final result = launch(
      AppStrings.instagramMessage(nameInstagram: instagram),
    );
    return result;
  }
}
