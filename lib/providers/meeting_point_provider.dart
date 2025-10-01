import 'dart:async';

import 'package:biux/data/models/meeting_point.dart';
import 'package:biux/data/repositories/meeting_point_repository.dart';
import 'package:flutter/material.dart';

class MeetingPointProvider extends ChangeNotifier {
  final MeetingPointRepository _repository;
  List<MeetingPoint> _meetingPoints = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _meetingPointsSubscription;

  MeetingPointProvider({required MeetingPointRepository repository})
      : _repository = repository;

  List<MeetingPoint> get meetingPoints => _meetingPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startListening() {
    if (_meetingPointsSubscription != null) return;

    _meetingPointsSubscription = _repository.getMeetingPoints().listen(
      (points) {
        _meetingPoints = points;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _meetingPointsSubscription?.cancel();
    _meetingPointsSubscription = null;
    _meetingPoints = [];
    _error = null;
    notifyListeners();
  }

  Future<MeetingPoint?> getMeetingPoint(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final point = await _repository.getMeetingPoint(id);

      _isLoading = false;
      _error = null;
      notifyListeners();

      return point;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
