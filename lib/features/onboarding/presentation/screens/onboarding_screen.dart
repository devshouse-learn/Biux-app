
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.directions_bike_rounded,
      title: 'Bienvenido a BiUX',
      description: 'La comunidad de ciclistas más grande. Conecta con otros ciclistas, organiza rodadas y explora nuevas rutas.',
      color: ColorTokens.primary30,
      emoji: '🚴',
    ),
    _OnboardingPage(
      icon: Icons.group_rounded,
      title: 'Grupos y Rodadas',
      description: 'Únete a grupos de ciclismo, organiza rodadas grupales y conoce ciclistas con tus mismos intereses.',
      color: Color(0xFF2E7D32),
      emoji: '👥',
    ),
    _OnboardingPage(
      icon: Icons.gps_fixed_rounded,
      title: 'Tracking GPS',
      description: 'Graba tus rodadas con GPS en tiempo real. Mide tu velocidad, distancia, calorías y más.',
      color: Color(0xFF1565C0),
      emoji: '📍',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Logros y Estadísticas',
      description: 'Desbloquea medallas, sube de nivel y compite con otros ciclistas. ¡Cada pedalazo cuenta!',
      color: Color(0xFFFF8F00),
      emoji: '🏆',
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'Seguridad Primero',
      description: 'Botón SOS de emergencia, reportes viales, registro de bicicletas y contactos de emergencia.',
      color: Color(0xFFC62828),
      emoji: '🛡️',
    ),
    _OnboardingPage(
      icon: Icons.storefront_rounded,
      title: 'Tienda y Comunidad',
      description: 'Compra y vende accesorios, comparte experiencias y mantente informado con educación vial.',
      color: Color(0xFF6A1B9A),
      emoji: '🛒',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    _currentPage == _pages.length - 1 ? '' : 'Saltar',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji grande
                        Text(page.emoji, style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        // Icono con fondo
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 64, color: page.color),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots + Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? _pages[_currentPage].color : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? '¡Comenzar!' : 'Siguiente',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
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

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String emoji;
  const _OnboardingPage({required this.icon, required this.title, required this.description, required this.color, required this.emoji});
}
