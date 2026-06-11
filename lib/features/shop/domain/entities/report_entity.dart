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
        return 'report_type_product';
      case ReportType.sellerReport:
        return 'report_type_seller';
      case ReportType.orderIssue:
        return 'report_type_order';
      case ReportType.securityAlert:
        return 'report_type_security';
      case ReportType.suggestion:
        return 'report_type_suggestion';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'report_status_pending';
      case ReportStatus.reviewing:
        return 'report_status_reviewing';
      case ReportStatus.resolved:
        return 'report_status_resolved';
      case ReportStatus.dismissed:
        return 'report_status_dismissed';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 5:
        return 'priority_urgent';
      case 4:
        return 'priority_high';
      case 3:
        return 'priority_medium';
      case 2:
        return 'priority_low';
      default:
        return 'priority_info';
    }
  }
}
