enum ReportReason { spam, harassment, inappropriate, fake, danger, other }

extension ReportReasonLabel on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.spam: return 'Spam o publicidad';
      case ReportReason.harassment: return 'Acoso o intimidación';
      case ReportReason.inappropriate: return 'Contenido inapropiado';
      case ReportReason.fake: return 'Perfil falso';
      case ReportReason.danger: return 'Comportamiento peligroso';
      case ReportReason.other: return 'Otro motivo';
    }
  }
}

class BlockEntity {
  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;
  const BlockEntity({required this.id, required this.blockerId, required this.blockedId, required this.createdAt});
}

class ReportEntity {
  final String id;
  final String reporterId;
  final String reportedId;
  final ReportReason reason;
  final String? description;
  final DateTime createdAt;
  final String status;
  const ReportEntity({
    required this.id, required this.reporterId, required this.reportedId,
    required this.reason, this.description, required this.createdAt, this.status = 'pending',
  });
}
