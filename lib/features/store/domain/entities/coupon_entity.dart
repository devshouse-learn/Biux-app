/// Entidad para cupones de descuento en la tienda
class CouponEntity {
  final String code;
  final String description;
  final CouponType type;
  final double value;
  final double? minPurchase;
  final DateTime? expirationDate;
  final bool isActive;

  CouponEntity({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.minPurchase,
    this.expirationDate,
    this.isActive = true,
  });

  /// Verificar si el cupón es válido
  bool get isValid {
    if (!isActive) return false;
    if (expirationDate != null && DateTime.now().isAfter(expirationDate!)) {
      return false;
    }
    return true;
  }

  /// Calcular el descuento aplicable
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;
    if (minPurchase != null && subtotal < minPurchase!) return 0;

    switch (type) {
      case CouponType.percentage:
        return subtotal * (value / 100);
      case CouponType.fixed:
        return value;
    }
  }
}

/// Tipos de cupones de descuento
enum CouponType {
  percentage, // Porcentaje (ej: 10%)
  fixed, // Monto fijo (ej: $5000)
}
