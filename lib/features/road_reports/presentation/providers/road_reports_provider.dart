import 'package:flutter/foundation.dart';
import 'package:biux/features/road_reports/domain/entities/road_report_entity.dart';
import 'package:biux/features/road_reports/data/datasources/road_reports_datasource.dart';

class RoadReportsProvider with ChangeNotifier {
  final _ds = RoadReportsDatasource();
  List<RoadReportEntity> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<RoadReportEntity> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _ds.getReports();
      _reports = data.map((m) {
        final rawConfirmedBy = m['confirmedBy'];
        final List<String> confirmedList = rawConfirmedBy is List
            ? rawConfirmedBy.map((e) => e.toString()).toList()
            : <String>[];

        return RoadReportEntity(
          id: m['id'] ?? '',
          userId: m['userId'] ?? '',
          userName: m['userName'] ?? '',
          type: m['type'] ?? '',
          description: m['description'] ?? '',
          latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
          confirmations: (m['confirmations'] as num?)?.toInt() ?? 0,
          confirmedBy: confirmedList,
          createdAt: m['createdAt'] != null
              ? (m['createdAt']).toDate()
              : DateTime.now(),
          isActive: m['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error cargando reportes: $e');
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createReport({
    required String userId,
    required String userName,
    required String type,
    required String description,
    required double lat,
    required double lng,
  }) async {
    await _ds.createReport(
      userId: userId,
      userName: userName,
      type: type,
      description: description,
      lat: lat,
      lng: lng,
    );
    await loadReports();
  }

  Future<bool> confirmReport(String reportId, String userId) async {
    final success = await _ds.confirmReport(reportId, userId);
    if (success) {
      await loadReports();
    }
    return success;
  }

  Future<void> dismissReport(String reportId) async {
    await _ds.dismissReport(reportId);
    await loadReports();
  }
}
