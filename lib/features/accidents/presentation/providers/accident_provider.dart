import 'package:flutter/foundation.dart';
import 'package:biux/features/accidents/data/datasources/accident_datasource.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';
import 'package:biux/core/services/app_logger.dart';

class AccidentProvider extends ChangeNotifier {
  final AccidentDatasource _ds = AccidentDatasource();
  List<AccidentEntity> _accidents = [];
  bool _loading = false;

  List<AccidentEntity> get accidents => _accidents;
  bool get loading => _loading;

  void listenAccidents() {
    _ds.getRecentAccidents().listen((list) {
      _accidents = list;
      notifyListeners();
    });
  }

  Future<void> report(AccidentEntity accident) async {
    try {
      await _ds.reportAccident(accident);
    } on Exception catch (e) {
      AppLogger.error(
        'Error reporting accident',
        error: e,
        tag: 'AccidentProvider',
      );
    }
  }

  Future<void> deleteAllAccidents() async {
    try {
      _loading = true;
      notifyListeners();
      await _ds.deleteAllAccidents();
      _accidents = [];
      _loading = false;
      notifyListeners();
    } on Exception catch (e) {
      AppLogger.error(
        'Error deleting accidents',
        error: e,
        tag: 'AccidentProvider',
      );
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteResolvedAccidents() async {
    try {
      _loading = true;
      notifyListeners();
      await _ds.deleteResolvedAccidents();
      _accidents = _accidents.where((a) => !a.resolved).toList();
      _loading = false;
      notifyListeners();
    } on Exception catch (e) {
      AppLogger.error(
        'Error deleting resolved accidents',
        error: e,
        tag: 'AccidentProvider',
      );
      _loading = false;
      notifyListeners();
    }
  }
}
