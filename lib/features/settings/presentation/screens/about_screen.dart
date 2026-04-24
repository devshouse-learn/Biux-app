import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Pantalla "Acerca de" con información de la app
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _version = '1.0.0';
          _buildNumber = '1';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF16242D);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      appBar: AppBar(
        title: const Text('Acerca de Biux'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'img/biux_logo_background_blue.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: primaryColor,
                    child: const Icon(
                      Icons.directions_bike,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Biux',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'La comunidad ciclista',
              style: TextStyle(
                fontSize: 16,
                color: (isDark ? Colors.white : primaryColor).withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_version.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v$_version ($_buildNumber)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white70
                        : primaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 40),

            // Features section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué es Biux?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Biux es la plataforma para ciclistas que te permite organizar rodadas, '
                    'unirte a grupos, chatear con otros ciclistas, rastrear tus rutas, '
                    'reportar zonas de peligro y mucho más.',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? Colors.white : primaryColor).withValues(
                        alpha: 0.7,
                      ),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Feature list
                  _FeatureTile(
                    icon: Icons.directions_bike_rounded,
                    title: 'Rodadas',
                    subtitle: 'Organiza y únete a rodadas grupales',
                    isDark: isDark,
                  ),
                  _FeatureTile(
                    icon: Icons.group_rounded,
                    title: 'Grupos',
                    subtitle: 'Crea y gestiona comunidades ciclistas',
                    isDark: isDark,
                  ),
                  _FeatureTile(
                    icon: Icons.chat_rounded,
                    title: 'Chat',
                    subtitle: 'Comunícate con otros ciclistas',
                    isDark: isDark,
                  ),
                  _FeatureTile(
                    icon: Icons.map_rounded,
                    title: 'Mapas',
                    subtitle: 'Explora rutas y zonas de peligro',
                    isDark: isDark,
                  ),
                  _FeatureTile(
                    icon: Icons.sos_rounded,
                    title: 'Emergencia',
                    subtitle: 'Botón SOS para situaciones de peligro',
                    isDark: isDark,
                  ),
                  _FeatureTile(
                    icon: Icons.store_rounded,
                    title: 'Tienda',
                    subtitle: 'Compra y vende productos ciclistas',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Social links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Síguenos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        icon: Icons.language,
                        label: 'Web',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Instagram',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: Icons.facebook_outlined,
                        label: 'Facebook',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Divider(
                    color: (isDark ? Colors.white : primaryColor).withValues(
                      alpha: 0.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2024 Biux. Todos los derechos reservados.',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : primaryColor).withValues(
                        alpha: 0.4,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hecho con ❤️ para ciclistas',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : primaryColor).withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF16242D);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : primaryColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDark ? Colors.white : primaryColor).withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF16242D);

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: (isDark ? Colors.white : primaryColor).withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
