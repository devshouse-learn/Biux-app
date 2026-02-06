import 'package:flutter/material.dart';
import '../../domain/models/promotion_request_model.dart';

class PromotionsProvider with ChangeNotifier {
  final List<PromotionRequestModel> _requests = [];

  List<PromotionRequestModel> get requests => List.unmodifiable(_requests);

  void addRequest(PromotionRequestModel req) {
    req.id = DateTime.now().millisecondsSinceEpoch.toString();
    _requests.insert(0, req);
    notifyListeners();
  }

  void approve(String id) {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'approved';
      notifyListeners();
    }
  }

  void reject(String id) {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'rejected';
      notifyListeners();
    }
  }
}
