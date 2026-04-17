import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widgets compartidos para todas las pantallas de Configuración.
/// Garantizan un estilo visual consistente en toda la sección de ajustes.
class SettingsWidgets {
  SettingsWidgets._();

  // ─── CONSTANTES DE ESTILO ───────────────────────────────────────
  static const double _cardRadius = 14.0;
  static const double _iconContainerRadius = 12.0;
  static const double _iconSize = 26.0;
  static const double _titleFontSize = 15.0;
  static const FontWeight _titleFontWeight = FontWeight.w600;
  static const double _subtitleFontSize = 13.0;
  static const double _arrowSize = 18.0;
  static const EdgeInsets _cardPadding = EdgeInsets.all(16);

  // ─── APP BAR ────────────────────────────────────────────────────
  static AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: ColorTokens.primary30,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // ─── SCAFFOLD BACKGROUND ────────────────────────────────────────
  static Color scaffoldBackground(bool isDark) {
    return isDark ? ColorTokens.primary30 : Colors.grey[50]!;
  }

  // ─── SECTION TITLE ──────────────────────────────────────────────
  static Widget buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── CARD DECORATION (compartida) ──────────────────────────────
  static BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? ColorTokens.primary20 : Colors.white,
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ─── ICON CONTAINER ─────────────────────────────────────────────
  static Widget _buildIconContainer(IconData icon, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_iconContainerRadius),
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
        size: _iconSize,
      ),
    );
  }

  // ─── OPTION BUTTON (con flecha →) ──────────────────────────────
  /// Card tappeable con ícono, título, subtítulo y flecha.
  /// Usado para navegar a sub-pantallas o mostrar diálogos.
  static Widget buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          padding: _cardPadding,
          decoration: _cardDecoration(isDark),
          child: Row(
            children: [
              _buildIconContainer(icon, isDark: isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: _titleFontSize,
                        fontWeight: _titleFontWeight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: _subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.white30 : Colors.black26,
                size: _arrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TOGGLE CARD (con switch) ──────────────────────────────────
  /// Card con ícono, título, subtítulo y un Switch.
  /// Usado para activar/desactivar opciones.
  static Widget buildToggleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        padding: _cardPadding,
        decoration: _cardDecoration(isDark),
        child: Row(
          children: [
            _buildIconContainer(icon, isDark: isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: _titleFontSize,
                      fontWeight: _titleFontWeight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: _subtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveThumbColor: isDark
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
              inactiveTrackColor: isDark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  // ─── MENU CARD (para la pantalla principal) ────────────────────
  /// Card del menú principal de Configuración con ícono grande y flecha.
  static Widget buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          padding: _cardPadding,
          decoration: _cardDecoration(isDark),
          child: Row(
            children: [
              _buildIconContainer(icon, isDark: isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: _subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.white30 : Colors.black26,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
