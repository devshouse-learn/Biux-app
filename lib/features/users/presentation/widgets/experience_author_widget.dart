import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget reutilizable para mostrar la información del autor de una experiencia
/// con la posibilidad de navegar a su perfil
class ExperienceAuthorWidget extends StatelessWidget {
  final BiuxUser author;
  final String timeAgo;
  final bool showFullInfo;
  final Color? textColor;

  const ExperienceAuthorWidget({
    Key? key,
    required this.author,
    required this.timeAgo,
    this.showFullInfo = true,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? ColorTokens.neutral80;

    print('=== EXPERIENCE AUTHOR WIDGET ===');
    print('Author ID: ${author.id}');
    print('Author FullName: ${author.fullName}');
    print('Author Photo: ${author.photo}');
    print('================================');

    return GestureDetector(
      onTap: () {
        // Navegar al perfil del usuario
        context.push('/user-profile/${author.id}');
      },
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorTokens.primary30.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: showFullInfo ? 20 : 16,
              backgroundColor: ColorTokens.neutral20,
              backgroundImage: author.photo.isNotEmpty
                  ? CachedNetworkImageProvider(
                      author.photo,
                      cacheManager: OptimizedCacheManager.avatarInstance,
                    )
                  : null,
              child: author.photo.isEmpty
                  ? Icon(
                      Icons.person,
                      size: showFullInfo ? 20 : 16,
                      color: ColorTokens.neutral60,
                    )
                  : null,
            ),
          ),

          SizedBox(width: 12),

          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  author.fullName.isNotEmpty
                      ? author.fullName
                      : 'Usuario sin nombre',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: showFullInfo ? 16 : 14,
                    color: effectiveTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // Username y tiempo
                if (showFullInfo) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      if (author.userName.isNotEmpty) ...[
                        Text(
                          '@${author.userName}',
                          style: TextStyle(
                            color: effectiveTextColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: effectiveTextColor.withValues(alpha: 0.5),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          timeAgo,
                          style: TextStyle(
                            color: effectiveTextColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: effectiveTextColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Indicador de que es clickeable
          Icon(
            Icons.chevron_right,
            color: effectiveTextColor.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Widget simple para avatar pequeño con navegación al perfil
class UserAvatarWidget extends StatelessWidget {
  final BiuxUser user;
  final double radius;
  final bool showBorder;

  const UserAvatarWidget({
    Key? key,
    required this.user,
    this.radius = 20,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/user-profile/${user.id}');
      },
      child: Container(
        decoration: showBorder
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorTokens.primary30.withValues(alpha: 0.3),
                  width: 2,
                ),
              )
            : null,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: ColorTokens.neutral20,
          backgroundImage: user.photo.isNotEmpty
              ? CachedNetworkImageProvider(
                  user.photo,
                  cacheManager: OptimizedCacheManager.avatarInstance,
                )
              : null,
          child: user.photo.isEmpty
              ? Icon(
                  Icons.person,
                  size: radius * 0.8,
                  color: ColorTokens.neutral60,
                )
              : null,
        ),
      ),
    );
  }
}
