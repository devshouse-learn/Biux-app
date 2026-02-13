import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';

/// Modelo de anuncio para mostrar en el feed
class AdvertisementData {
  final String userId;
  final String userName;
  final String userFullName;
  final String? userPhotoUrl;
  final String description;
  final String? callToActionText;

  const AdvertisementData({
    required this.userId,
    required this.userName,
    required this.userFullName,
    this.userPhotoUrl,
    this.description = 'Descubre este perfil increíble',
    this.callToActionText = 'Ver Perfil',
  });
}

/// Widget de anuncio publicitario tipo Instagram Stories
/// Se muestra en la sección de feeds con opción de ir al perfil
class AdvertisementWidget extends StatelessWidget {
  final AdvertisementData advertisement;
  final double? height;

  const AdvertisementWidget({
    super.key,
    required this.advertisement,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  ColorTokens.primary30.withValues(alpha: 0.9),
                  ColorTokens.secondary50.withValues(alpha: 0.7),
                ]
              : [
                  ColorTokens.secondary50.withValues(alpha: 0.8),
                  ColorTokens.primary30.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ColorTokens.neutral60.withValues(alpha: 0.3)
              : ColorTokens.neutral100.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background imagen de perfil (blurred)
            if (advertisement.userPhotoUrl != null)
              Positioned.fill(
                child: OptimizedNetworkImage(
                  imageUrl: advertisement.userPhotoUrl!,
                  imageType: 'profile',
                  fit: BoxFit.cover,
                ),
              ),

            // Overlay oscuro para legibilidad
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Badge de "PUBLICIDAD"
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PUBLICIDAD',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.primary30,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar y nombre
                  Row(
                    children: [
                      // Avatar circular
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                          color: ColorTokens.neutral100.withValues(alpha: 0.3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: advertisement.userPhotoUrl != null
                              ? OptimizedNetworkImage(
                                  imageUrl: advertisement.userPhotoUrl!,
                                  imageType: 'profile',
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Nombre y usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              advertisement.userFullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '@${advertisement.userName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Descripción y botón
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advertisement.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Botón "Ver Perfil"
                      GestureDetector(
                        onTap: () {
                          // Navegar al perfil del usuario promocionado
                          context.push('/user-profile/${advertisement.userId}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            advertisement.callToActionText ?? 'Ver Perfil',
                            style: TextStyle(
                              color: ColorTokens.primary30,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generador de datos de anuncios de prueba
class AdvertisementDataGenerator {
  static const List<Map<String, String>> _mockAdvertisements = [
    {
      'userId': 'ad_001',
      'userName': 'aventurero_mx',
      'fullName': 'Carlos Aventurero',
      'photoUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      'description': 'Ciclista de montaña - Explora las mejores rutas',
    },
    {
      'userId': 'ad_002',
      'userName': 'bicicleta_pro',
      'fullName': 'María Ciclos',
      'photoUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'description': 'Entrenador certificado en ciclismo urbano',
    },
    {
      'userId': 'ad_003',
      'userName': 'ruta_extrema',
      'fullName': 'Juan Pedales',
      'photoUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      'description': 'Comunidad de ciclistas de ruta más grande',
    },
    {
      'userId': 'ad_004',
      'userName': 'touring_bikes',
      'fullName': 'Aventuras en Dos Ruedas',
      'photoUrl':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
      'description': 'Viajes en bicicleta alrededor del mundo',
    },
  ];

  /// Genera un anuncio aleatorio para mostrar
  static AdvertisementData generateRandom() {
    final ad =
        _mockAdvertisements[DateTime.now().millisecond % _mockAdvertisements.length];
    return AdvertisementData(
      userId: ad['userId']!,
      userName: ad['userName']!,
      userFullName: ad['fullName']!,
      userPhotoUrl: ad['photoUrl'],
      description: ad['description']!,
      callToActionText: 'Ver Perfil',
    );
  }

  /// Genera un anuncio específico
  static AdvertisementData generate({
    required String userId,
    required String userName,
    required String userFullName,
    String? userPhotoUrl,
    String description = 'Descubre este perfil increíble',
  }) {
    return AdvertisementData(
      userId: userId,
      userName: userName,
      userFullName: userFullName,
      userPhotoUrl: userPhotoUrl,
      description: description,
      callToActionText: 'Ver Perfil',
    );
  }
}
