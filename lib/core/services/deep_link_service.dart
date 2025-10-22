import 'package:go_router/go_router.dart';

/// Servicio para manejar deep links y app links
class DeepLinkService {
  /// Genera un deep link para una rodada
  static String generateRideDeepLink(String rideId) {
    return 'biux://ride/$rideId';
  }

  /// Genera un app link (HTTPS) para una rodada
  static String generateRideAppLink(String rideId) {
    return 'https://biux.devshouse.org/ride/$rideId';
  }

  /// Genera un app link (HTTPS) para un post
  static String generatePostAppLink(String postId) {
    return 'https://biux.devshouse.org/posts/$postId';
  }

  /// Genera un app link (HTTPS) para un grupo
  static String generateGroupAppLink(String groupId) {
    return 'https://biux.devshouse.org/group/$groupId';
  }

  /// Genera un app link (HTTPS) para un usuario
  static String generateUserAppLink(String userId) {
    return 'https://biux.devshouse.org/user/$userId';
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

    // Manejar esquema https:// (App Links) con dominio personalizado
    if (uri.scheme == 'https' && uri.host == 'biux.devshouse.org') {
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
        router.push('/rides/$rideId');
      }
      return;
    }

    // biux://posts/{postId}
    if (uri.host == 'posts') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final postId = segments[0];
        print('📝 Navegando a post: $postId');
        // Navegar al feed y luego al post específico
        router.push('/stories');
      }
      return;
    }

    // biux://group/{groupId}
    if (uri.host == 'group') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final groupId = segments[0];
        print('👥 Navegando a grupo: $groupId');
        router.push('/groups/$groupId');
      }
      return;
    }

    // biux://user/{userId} o biux://user-profile/{userId}
    if (uri.host == 'user' || uri.host == 'user-profile') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final userId = segments[0];
        print('👤 Navegando a perfil: $userId');
        router.push('/user-profile/$userId');
      }
      return;
    }
  }

  static void _handleAppLink(Uri uri, GoRouter router) {
    print('🔗 Manejando app link: ${uri.toString()}');

    // https://biux.devshouse.org/ride/{rideId}
    if (uri.path.startsWith('/ride/')) {
      final rideId = uri.pathSegments.last;
      print('🚴 Navegando a rodada desde app link: $rideId');
      router.push('/rides/$rideId');
      return;
    }

    // https://biux.devshouse.org/posts/{postId}
    if (uri.path.startsWith('/posts/')) {
      final postId = uri.pathSegments.last;
      print('📝 Navegando a post desde app link: $postId');
      router.push('/stories');
      return;
    }

    // https://biux.devshouse.org/group/{groupId}
    if (uri.path.startsWith('/group/')) {
      final groupId = uri.pathSegments.last;
      print('👥 Navegando a grupo desde app link: $groupId');
      router.push('/groups/$groupId');
      return;
    }

    // https://biux.devshouse.org/user/{userId}
    if (uri.path.startsWith('/user/')) {
      final userId = uri.pathSegments.last;
      print('👤 Navegando a perfil desde app link: $userId');
      router.push('/user-profile/$userId');
      return;
    }
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
