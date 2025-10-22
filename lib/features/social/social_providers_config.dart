import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Domain
import 'domain/repositories/notifications_repository.dart';
import 'domain/repositories/likes_repository.dart';
import 'domain/repositories/comments_repository.dart';
import 'domain/repositories/attendees_repository.dart';
import '../users/domain/repositories/user_repository.dart';

// Data
import 'data/repositories/notifications_repository_impl.dart';
import 'data/repositories/likes_repository_impl.dart';
import 'data/repositories/comments_repository_impl.dart';
import 'data/repositories/attendees_repository_impl.dart';
import '../users/data/repositories/user_repository_impl.dart';
import '../users/data/datasources/user_remote_datasource.dart';

// Providers
import 'presentation/providers/notifications_provider.dart';
import 'presentation/providers/likes_provider.dart';
import 'presentation/providers/comments_provider.dart';
import 'presentation/providers/attendees_provider.dart';

/// Configuración de providers del feature social
class SocialProvidersConfig {
  /// Crea la lista de providers para el feature social
  static List<ChangeNotifierProvider> getProviders() {
    // Obtener usuario actual
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Si no hay usuario autenticado, retornar lista vacía
      return [];
    }

    final userId = currentUser.uid;
    final userName = currentUser.displayName?.trim().isNotEmpty == true
        ? currentUser.displayName!.trim()
        : currentUser.email?.split('@').first ?? 'Usuario';
    final userPhoto = currentUser.photoURL;

    // Crear repositorios
    final notificationsRepository = NotificationsRepositoryImpl();
    final likesRepository = LikesRepositoryImpl();
    final commentsRepository = CommentsRepositoryImpl();
    final attendeesRepository = AttendeesRepositoryImpl();
    final userRepository = UserRepositoryImpl(
      remoteDataSource: UserRemoteDataSourceImpl(),
    );

    return [
      // Provider de notificaciones
      ChangeNotifierProvider<NotificationsProvider>(
        create: (_) => NotificationsProvider(
          repository: notificationsRepository,
          userId: userId,
        ),
      ),

      // Provider de likes
      ChangeNotifierProvider<LikesProvider>(
        create: (_) => LikesProvider(
          repository: likesRepository,
          notificationsRepository: notificationsRepository,
          userId: userId,
          userName: userName,
          userPhoto: userPhoto,
        ),
      ),

      // Provider de comentarios
      ChangeNotifierProvider<CommentsProvider>(
        create: (_) => CommentsProvider(
          repository: commentsRepository,
          notificationsRepository: notificationsRepository,
          userId: userId,
          userName: userName,
          userPhoto: userPhoto,
        ),
      ),

      // Provider de asistentes
      ChangeNotifierProvider<AttendeesProvider>(
        create: (_) => AttendeesProvider(
          repository: attendeesRepository,
          notificationsRepository: notificationsRepository,
          userRepository:
              userRepository, // ⚠️ Agregado para obtener datos completos
          userId: userId,
          userName: userName,
          userPhoto: userPhoto,
        ),
      ),
    ];
  }
}
