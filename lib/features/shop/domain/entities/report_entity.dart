/// Tipo de reporte de la tienda
enum ReportType {
  productReport,
  sellerReport,
  orderIssue,
  securityAlert,
  suggestion,
}

/// Estado del reporte
enum ReportStatus { pending, reviewing, resolved, dismissed }

/// Entidad de reporte
class ReportEntity {
  final String id;
  final ReportType type;
  final ReportStatus status;
  final String reporterId;
  final String reporterName;
  final String? targetProductId;
  final String? targetSellerId;
  final String? targetOrderId;
  final String title;
  final String description;
  final List<String> evidence;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminResponse;
  final int priority;

  const ReportEntity({
    required this.id,
    required this.type,
    this.status = ReportStatus.pending,
    required this.reporterId,
    required this.reporterName,
    this.targetProductId,
    this.targetSellerId,
    this.targetOrderId,
    required this.title,
    required this.description,
    this.evidence = const [],
    required this.createdAt,
    this.resolvedAt,
    this.adminResponse,
    this.priority = 1,
  });

  String get typeLabel {
    switch (type) {
      case ReportType.productReport:
        return 'Reporte de Producto';
      case ReportType.sellerReport:
        return 'Reporte de Vendedor';
      case ReportType.orderIssue:
        return 'Problema con Pedido';
      case ReportType.securityAlert:
        return 'Alerta de Seguridad';
      case ReportType.suggestion:
        return 'Sugerencia';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.reviewing:
        return 'En Revisión';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.dismissed:
        return 'Descartado';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 5:
        return '🔴 Urgente';
      case 4:
        return '🟠 Alta';
      case 3:
        return '🟡 Media';
      case 2:
        return '🔵 Baja';
      default:
        return '⚪ Informativa';
    }
  }
}
