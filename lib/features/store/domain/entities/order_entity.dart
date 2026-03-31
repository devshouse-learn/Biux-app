/// Estados de un pedido
enum OrderStatus {
  pendiente, // Pendiente de pago
  pagado, // Pagado pero no enviado
  enviado, // En camino
  entregado, // Entregado al cliente
  cancelado; // Cancelado

  String get displayName {
    switch (this) {
      case OrderStatus.pendiente:
        return 'order_status_pending';
      case OrderStatus.pagado:
        return 'order_status_paid';
      case OrderStatus.enviado:
        return 'order_status_shipped';
      case OrderStatus.entregado:
        return 'order_status_delivered';
      case OrderStatus.cancelado:
        return 'order_status_cancelled';
    }
  }
}

/// Método de pago
enum PaymentMethod {
  efectivo,
  tarjeta,
  transferencia,
  paypal,
  otro;

  String get displayName {
    switch (this) {
      case PaymentMethod.efectivo:
        return 'payment_cash';
      case PaymentMethod.tarjeta:
        return 'payment_card';
      case PaymentMethod.transferencia:
        return 'payment_transfer';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.otro:
        return 'payment_other';
    }
  }
}

/// Item del pedido (producto + cantidad)
class OrderItemEntity {
  final String productoId;
  final String nombre;
  final double precioUnitario;
  final int cantidad;
  final String? imagenUrl;

  const OrderItemEntity({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    this.imagenUrl,
  });

  /// Subtotal del item
  double get subtotal => precioUnitario * cantidad;
}

/// Entidad de dominio para Pedido
class OrderEntity {
  final String id;
  final String userId; // ID del usuario que realizó la compra
  final String? userName; // Nombre del usuario
  final List<OrderItemEntity> items; // Productos del pedido
  final double total; // Total del pedido
  final OrderStatus estado;
  final PaymentMethod? metodoPago;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? direccionEnvio;
  final String? notas;
  final String? trackingNumber; // Número de seguimiento

  const OrderEntity({
    required this.id,
    required this.userId,
    this.userName,
    required this.items,
    required this.total,
    this.estado = OrderStatus.pendiente,
    this.metodoPago,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.direccionEnvio,
    this.notas,
    this.trackingNumber,
  });

  /// Cantidad total de productos en el pedido
  int get cantidadTotal {
    return items.fold(0, (sum, item) => sum + item.cantidad);
  }

  /// Si el pedido puede ser cancelado
  bool get puedeCancelarse {
    return estado == OrderStatus.pendiente || estado == OrderStatus.pagado;
  }

  /// Si el pedido está activo (no cancelado ni entregado)
  bool get estaActivo {
    return estado != OrderStatus.cancelado && estado != OrderStatus.entregado;
  }

  /// Copiar pedido con cambios
  OrderEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    List<OrderItemEntity>? items,
    double? total,
    OrderStatus? estado,
    PaymentMethod? metodoPago,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? direccionEnvio,
    String? notas,
    String? trackingNumber,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      direccionEnvio: direccionEnvio ?? this.direccionEnvio,
      notas: notas ?? this.notas,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }
}
