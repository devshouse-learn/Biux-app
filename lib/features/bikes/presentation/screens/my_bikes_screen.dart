import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';

/// Pantalla principal para ver todas las bicicletas del usuario
class MyBikesScreen extends StatefulWidget {
  const MyBikesScreen({super.key});

  @override
  State<MyBikesScreen> createState() => _MyBikesScreenState();
}

class _MyBikesScreenState extends State<MyBikesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar bicicletas del usuario al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserBikes();
    });
  }

  void _loadUserBikes() {
    final bikeProvider = context.read<BikeProvider>();
    // Obtener el userId del usuario autenticado
    final userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('🔑 MyBikesScreen: Usuario autenticado - userId: "$userId"');

    if (userId != null) {
      bikeProvider.loadUserBikes(userId);
    } else {
      debugPrint('❌ MyBikesScreen: No hay usuario autenticado');
      // Si no hay usuario autenticado, mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('must_login_bikes'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      body: Consumer<BikeProvider>(
        builder: (context, bikeProvider, child) {
          if (bikeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          if (bikeProvider.hasError) {
            return _buildErrorState(bikeProvider.errorMessage);
          }

          final bikes = bikeProvider.userBikes;

          if (bikes.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildStatsCard(bikeProvider.getUserBikeStats()),
              Expanded(child: _buildBikesList(bikes)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/bikes/register');
        },
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l.t('register_bike')),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: ColorTokens.error50),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? l.t('error_loading_bikes'),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserBikes,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: Colors.white,
            ),
            child: Text(l.t('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bike, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            l.t('no_bikes_registered'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('register_first_bike'),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('tap_add_first_bike'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, int> stats) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.primary30,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(l.t('total_bikes'), stats['total'] ?? 0, Colors.white),
          _buildStatDivider(),
          _buildStatItem(
            l.t('active_bikes'),
            stats['active'] ?? 0,
            Colors.green,
          ),
          _buildStatDivider(),
          _buildStatItem(l.t('stolen_stat'), stats['stolen'] ?? 0, Colors.red),
          _buildStatDivider(),
          _buildStatItem(
            l.t('verified_bikes'),
            stats['verified'] ?? 0,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: Colors.white30);
  }

  Widget _buildBikesList(List<BikeEntity> bikes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        final bike = bikes[index];
        return _buildBikeCard(bike);
      },
    );
  }

  Widget _buildBikeCard(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/bikes/${bike.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen de la bicicleta
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OptimizedNetworkImage(
                  imageUrl: bike.mainPhoto,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Información de la bicicleta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bike.brand} ${bike.model}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bike.year} • ${bike.color} • ${l.t(bike.type.displayName)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(bike.status),
                  ],
                ),
              ),
              // Icono de flecha
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BikeStatus status) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case BikeStatus.active:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case BikeStatus.stolen:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.warning;
        break;
      case BikeStatus.recovered:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.restore;
        break;
      case BikeStatus.verified:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.verified;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            l.t(status.displayName),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
