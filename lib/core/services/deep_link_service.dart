import 'package:go_router/go_router.dart';

/// Servicio para manejar deep links y app links
class DeepLinkService {
  /// Genera un deep link para una rodada
  static String generateRideDeepLink(String rideId) {
    return 'biux://ride/$rideId';
  }

  /// Genera un app link (HTTPS) para una rodada
  static String generateRideAppLink(String rideId) {
    return 'https://biux.app/ride/$rideId';
  }

  /// Parsea un deep link y navega a la pantalla correspondiente
  static void handleDeepLink(String? link, GoRouter router) {
    if (link == null || link.isEmpty) return;

    final uri = Uri.parse(link);

    // Manejar esquema biux://
    if (uri.scheme == 'biux') {
      _handleBiuxDeepLink(uri, router);
      return;
    }

    // Manejar esquema https:// (App Links)
    if (uri.scheme == 'https' && uri.host == 'biux.app') {
      _handleAppLink(uri, router);
      return;
    }
  }

  static void _handleBiuxDeepLink(Uri uri, GoRouter router) {
    print('🔗 Manejando deep link biux: ${uri.toString()}');

    // biux://ride/{rideId}
    if (uri.host == 'ride') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final rideId = segments[0];
        print('🚴 Navegando a rodada: $rideId');
        router.go('/rides/$rideId');
      }
    }
    // Aquí puedes agregar más esquemas:
    // biux://group/{groupId}
    // biux://user/{userId}
    // etc.
  }

  static void _handleAppLink(Uri uri, GoRouter router) {
    print('🔗 Manejando app link: ${uri.toString()}');

    // https://biux.app/ride/{rideId}
    if (uri.path.startsWith('/ride/')) {
      final rideId = uri.pathSegments.last;
      print('🚴 Navegando a rodada desde app link: $rideId');
      router.go('/rides/$rideId');
    }
    // Puedes agregar más rutas de app links aquí
  }

  /// Texto para compartir una rodada
  static String generateShareText({
    required String rideName,
    required String rideId,
    String? groupName,
  }) {
    final link = generateRideAppLink(rideId);

    if (groupName != null) {
      return '🚴 ¡Únete a la rodada "$rideName" con $groupName!\n\n'
          '📍 Tap para ver detalles e inscribirte:\n'
          '$link';
    }

    return '🚴 ¡Únete a la rodada "$rideName"!\n\n'
        '📍 Tap para ver detalles e inscribirte:\n'
        '$link';
  }
}
