import 'package:biux/data/models/meeting_point.dart';
import 'package:biux/data/repositories/meeting_point_repository.dart';
import 'package:flutter/material.dart';

class MeetingPointProvider extends ChangeNotifier {
  final MeetingPointRepository _repository;
  List<MeetingPoint> _meetingPoints = [];
  bool _isLoading = false;
  String? _error;

  MeetingPointProvider({required MeetingPointRepository repository})
      : _repository = repository {
    _loadMeetingPoints();
  }

  List<MeetingPoint> get meetingPoints => _meetingPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadMeetingPoints() {
    _repository.getMeetingPoints().listen(
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
}
