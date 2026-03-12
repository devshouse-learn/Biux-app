import 'dart:async';
import 'package:flutter/material.dart';
import 'package:biux/core/services/connectivity_service.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget que muestra un banner de "Sin conexión" cuando se pierde internet.
/// Se coloca en un Column encima del contenido principal (sin child requerido).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<ConnectivityStatus> _subscription;
  late final AnimationController _animController;
  bool _isOffline = false;
  bool _showReconnected = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final connectivity = ConnectivityService();
    _isOffline = !connectivity.isOnline;
    if (_isOffline) _animController.forward();

    _subscription = connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.offline && !_isOffline) {
        setState(() => _isOffline = true);
        _animController.forward();
      } else if (status == ConnectivityStatus.online && _isOffline) {
        setState(() {
          _isOffline = false;
          _showReconnected = true;
        });
        // Mostrar "Conexión restaurada" por 2 segundos y luego ocultar
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showReconnected = false);
            _animController.reverse();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline && !_showReconnected) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_animController),
      child: Material(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          color: _showReconnected ? Colors.green.shade700 : ColorTokens.error50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _showReconnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _showReconnected
                    ? 'Conexión restaurada'
                    : 'Sin conexión a internet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builder helper: reconstruye el widget basado en el estado de conectividad
class ConnectivityBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;

  const ConnectivityBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: ConnectivityService().statusStream,
      initialData: ConnectivityService().status,
      builder: (context, snapshot) {
        final isOnline = snapshot.data != ConnectivityStatus.offline;
        return builder(context, isOnline);
      },
    );
  }
}
