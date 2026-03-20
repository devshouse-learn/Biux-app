import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/store/domain/entities/coupon_entity.dart';

/// Implementación de cupones respaldada por Firestore.
///
/// Colección: `cupones`
/// Permite gestionar cupones de forma dinámica desde el backend.
class CouponDatasourceImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'cupones';

  /// Cache local para evitar lecturas excesivas.
  Map<String, CouponEntity>? _cache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 10);

  /// Obtiene un cupón por código.
  Future<CouponEntity?> getCouponByCode(String code) async {
    try {
      final upperCode = code.toUpperCase();

      // Intentar cache primero
      if (_isCacheValid && _cache!.containsKey(upperCode)) {
        return _cache![upperCode];
      }

      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: upperCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final coupon = _couponFromDoc(doc);

      // Actualizar cache
      _cache ??= {};
      _cache![upperCode] = coupon;

      return coupon;
    } catch (e) {
      throw Exception('Error obteniendo cupón: $e');
    }
  }

  /// Valida si un cupón existe y es válido.
  Future<bool> validateCoupon(String code) async {
    final coupon = await getCouponByCode(code);
    return coupon?.isValid ?? false;
  }

  /// Obtiene todos los cupones activos.
  Future<List<CouponEntity>> getAvailableCoupons() async {
    try {
      if (_isCacheValid && _cache != null) {
        return _cache!.values.where((c) => c.isValid).toList();
      }

      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final coupons = snapshot.docs.map(_couponFromDoc).toList();

      // Actualizar cache completo
      _cache = {for (final c in coupons) c.code: c};
      _cacheTimestamp = DateTime.now();

      return coupons.where((c) => c.isValid).toList();
    } catch (e) {
      throw Exception('Error obteniendo cupones disponibles: $e');
    }
  }

  /// Registra el uso de un cupón (incrementa contador).
  Future<void> recordCouponUsage(String code, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'usageCount': FieldValue.increment(1),
          'lastUsedAt': FieldValue.serverTimestamp(),
          'usedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw Exception('Error registrando uso de cupón: $e');
    }
  }

  /// Invalida el cache local.
  void clearCache() {
    _cache = null;
    _cacheTimestamp = null;
  }

  bool get _isCacheValid {
    if (_cache == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  CouponEntity _couponFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponEntity(
      code: data['code'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: _parseCouponType(data['type'] as String?),
      value: (data['value'] as num?)?.toDouble() ?? 0,
      minPurchase: (data['minPurchase'] as num?)?.toDouble(),
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  CouponType _parseCouponType(String? type) {
    switch (type) {
      case 'fixed':
        return CouponType.fixed;
      case 'percentage':
      default:
        return CouponType.percentage;
    }
  }
}
