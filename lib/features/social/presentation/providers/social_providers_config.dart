import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Auth
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart'
    as app_auth;

// Data
import 'package:biux/features/social/data/repositories/notifications_repository_impl.dart';
import 'package:biux/features/social/data/repositories/likes_repository_impl.dart';
import 'package:biux/features/social/data/repositories/comments_repository_impl.dart';
import 'package:biux/features/social/data/repositories/attendees_repository_impl.dart';

// Providers
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/social/presentation/providers/likes_provider.dart';
import 'package:biux/features/social/presentation/providers/comments_provider.dart';
import 'package:biux/features/social/presentation/providers/attendees_provider.dart';

/// Configuración de providers del feature social
class SocialProvidersConfig {
  /// Crea la lista de providers para el feature social
  static List<SingleChildWidget> getProviders() {
    return [
      // Provider de notificaciones - Se inicializa con lazy loading
      ChangeNotifierProxyProvider<
        app_auth.AuthProvider,
        NotificationsProvider?
      >(
        create: (_) => null, // Inicialmente null
        update: (context, authProvider, previous) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) return null;

          // Si ya existe y el userId es el mismo, reutilizar
          if (previous != null && previous.userId == currentUser.uid) {
            return previous;
          }

          // Crear nuevo provider con el usuario autenticado
          final notificationsRepository = NotificationsRepositoryImpl();
          return NotificationsProvider(
            repository: notificationsRepository,
            userId: currentUser.uid,
          );
        },
      ),

      // Provider de likes - Lazy loading
      ChangeNotifierProxyProvider<app_auth.AuthProvider, LikesProvider?>(
        create: (_) => null,
        update: (context, authProvider, previous) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) return null;

          if (previous != null && previous.userId == currentUser.uid) {
            return previous;
          }

          final likesRepository = LikesRepositoryImpl();
          // final notificationsRepository = NotificationsRepositoryImpl(); // ✅ Not needed
          return LikesProvider(
            repository: likesRepository,
            // notificationsRepository: notificationsRepository, // ✅ Not needed
            userId: currentUser.uid,
          );
        },
      ),

      // Provider de comentarios - Lazy loading
      ChangeNotifierProxyProvider<app_auth.AuthProvider, CommentsProvider?>(
        create: (_) => null,
        update: (context, authProvider, previous) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) return null;

          if (previous != null) {
            return previous;
          }

          final commentsRepository = CommentsRepositoryImpl();
          final notificationsRepository = NotificationsRepositoryImpl();
          return CommentsProvider(
            repository: commentsRepository,
            notificationsRepository: notificationsRepository,
            userId: currentUser.uid,
          );
        },
      ),

      // Provider de asistentes - Lazy loading
      ChangeNotifierProxyProvider<app_auth.AuthProvider, AttendeesProvider?>(
        create: (_) => null,
        update: (context, authProvider, previous) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) return null;

          if (previous != null && previous.userId == currentUser.uid) {
            return previous;
          }

          final attendeesRepository = AttendeesRepositoryImpl();
          // final notificationsRepository = NotificationsRepositoryImpl(); // ✅ Not needed
          return AttendeesProvider(
            repository: attendeesRepository,
            // notificationsRepository: notificationsRepository, // ✅ Not needed
            userId: currentUser.uid,
          );
        },
      ),
    ];
  }
}
