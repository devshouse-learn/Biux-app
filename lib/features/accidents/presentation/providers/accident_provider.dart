import 'package:flutter/foundation.dart';
import 'package:biux/features/accidents/data/datasources/accident_datasource.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';

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
    } catch (e) {
      debugPrint('Error reporting accident: $e');
    }
  }
}
