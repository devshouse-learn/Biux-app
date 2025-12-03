import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Utilidad para manejar diseño responsive en web
class ResponsiveHelper {
  /// Ancho máximo para vista móvil en web
  static const double maxMobileWidth = 600.0;
  
  /// Verifica si estamos en web
  static bool get isWeb => kIsWeb;
  
  /// Obtiene el ancho apropiado para la app en web
  static double getAppWidth(BuildContext context) {
    if (!isWeb) return MediaQuery.of(context).size.width;
    
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > maxMobileWidth ? maxMobileWidth : screenWidth;
  }
  
  /// Wrapper para centrar la app en pantallas grandes
  static Widget wrapForWeb(Widget child, BuildContext context) {
    if (!isWeb) return child;
    
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth <= maxMobileWidth) {
      return child;
    }
    
    // Centrar la app en pantallas grandes
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Container(
          width: maxMobileWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// Obtiene el padding horizontal apropiado
  static double getHorizontalPadding(BuildContext context) {
    if (!isWeb) return 16.0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxMobileWidth) return 0.0;
    return 16.0;
  }
}
