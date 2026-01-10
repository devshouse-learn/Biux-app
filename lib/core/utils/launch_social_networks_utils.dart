import 'package:biux/core/config/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchSocialNetworks {
  Future<bool> launchwhatsapp(String whatsapp, String name) async {
    final url = Uri.parse(
      AppStrings.whatsappMessage(whatsappNumber: whatsapp, name: name),
    );
    final result = await launchUrl(url, mode: LaunchMode.externalApplication);
    return result;
  }

  Future<bool> launchFacebook(String facebook) async {
    final url = Uri.parse(facebook);
    final result = await launchUrl(url, mode: LaunchMode.externalApplication);
    return result;
  }

  Future<bool> launchInstagram(String instagram) async {
    final url = Uri.parse(
      AppStrings.instagramMessage(nameInstagram: instagram),
    );
    final result = await launchUrl(url, mode: LaunchMode.externalApplication);
    return result;
  }
}
