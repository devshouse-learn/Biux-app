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

  /// Genera un app link (HTTPS) para un post/historia
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

  /// Genera un app link (HTTPS) para una historia
  static String generateStoryAppLink(String storyId) {
    return 'https://biux.devshouse.org/stories/$storyId';
  }

  /// Parsea un deep link y navega a la pantalla correspondiente
  static Future<void> handleDeepLink(String? link, GoRouter router) async {
    if (link == null || link.isEmpty) return;

    print('🔗 Procesando deep link: $link');
    
    try {
      final uri = Uri.parse(link);
      print('🔗 URI Schema: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');

      // Manejar esquema biux://
      if (uri.scheme == 'biux') {
        await _handleBiuxDeepLink(uri, router);
        return;
      }

      // Manejar esquema https:// (App Links) con dominio personalizado
      if (uri.scheme == 'https' && uri.host == 'biux.devshouse.org') {
        await _handleAppLink(uri, router);
        return;
      }

      print('⚠️ Esquema o host no reconocido: ${uri.scheme}://${uri.host}');
    } catch (e) {
      print('❌ Error procesando deep link: $e');
    }
  }

  static Future<void> _handleBiuxDeepLink(Uri uri, GoRouter router) async {
    print('🔗 Manejando deep link biux: ${uri.toString()}');

    // biux://ride/{rideId}
    if (uri.host == 'ride') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final rideId = segments.first;
        print('🚴 Navegando a rodada: $rideId');
        router.push('/rides/$rideId');
      }
      return;
    }

    // biux://posts/{postId}
    if (uri.host == 'posts') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final postId = segments.first;
        print('📝 Navegando a post: $postId');
        router.push('/stories');
      }
      return;
    }

    // biux://group/{groupId}
    if (uri.host == 'group') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final groupId = segments.first;
        print('👥 Navegando a grupo: $groupId');
        router.push('/groups/$groupId');
      }
      return;
    }

    // biux://user/{userId} o biux://user-profile/{userId}
    if (uri.host == 'user' || uri.host == 'user-profile') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final userId = segments.first;
        print('👤 Navegando a perfil: $userId');
        router.push('/user-profile/$userId');
      }
      return;
    }

    print('⚠️ Host de deep link no reconocido: ${uri.host}');
  }

  static Future<void> _handleAppLink(Uri uri, GoRouter router) async {
    print('🔗 Manejando app link: ${uri.toString()}');
    print('🔗 Path: ${uri.path}, Segments: ${uri.pathSegments}');

    // https://biux.devshouse.org/ride/{rideId}
    if (uri.path.startsWith('/ride/')) {
      final rideId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (rideId != null && rideId.isNotEmpty) {
        print('🚴 Navegando a rodada desde app link: $rideId');
        router.push('/rides/$rideId');
      }
      return;
    }

    // https://biux.devshouse.org/posts/{postId}
    if (uri.path.startsWith('/posts/')) {
      final postId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (postId != null && postId.isNotEmpty) {
        print('📝 Navegando a post desde app link: $postId');
        router.push('/stories');
      }
      return;
    }

    // https://biux.devshouse.org/stories/{storyId}
    if (uri.path.startsWith('/stories/')) {
      final storyId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (storyId != null && storyId.isNotEmpty) {
        print('📸 Navegando a historia desde app link: $storyId');
        router.push('/stories');
      }
      return;
    }

    // https://biux.devshouse.org/group/{groupId}
    if (uri.path.startsWith('/group/')) {
      final groupId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (groupId != null && groupId.isNotEmpty) {
        print('👥 Navegando a grupo desde app link: $groupId');
        router.push('/groups/$groupId');
      }
      return;
    }

    // https://biux.devshouse.org/user/{userId}
    if (uri.path.startsWith('/user/')) {
      final userId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (userId != null && userId.isNotEmpty) {
        print('👤 Navegando a perfil desde app link: $userId');
        router.push('/user-profile/$userId');
      }
      return;
    }

    print('⚠️ Path de app link no reconocido: ${uri.path}');
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

  /// Texto para compartir una historia
  static String generateStoryShareText({
    required String userName,
    required String storyId,
  }) {
    final link = generateStoryAppLink(storyId);

    return '📸 ¡Mira la historia de $userName!\n\n'
        '👀 Tap para verla:\n'
        '$link';
  }

  /// Texto para compartir un grupo
  static String generateGroupShareText({
    required String groupName,
    required String groupId,
  }) {
    final link = generateGroupAppLink(groupId);

    return '👥 ¡Únete al grupo "$groupName"!\n\n'
        '🔗 Tap para más información:\n'
        '$link';
  }

  /// Texto para compartir un usuario
  static String generateUserShareText({
    required String userName,
    required String userId,
  }) {
    final link = generateUserAppLink(userId);

    return '👤 ¡Sigue a $userName en BIUX!\n\n'
        '🔗 Tap para ver su perfil:\n'
        '$link';
  }
}
