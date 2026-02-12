import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/models/promotion_request_model.dart';

class PromotionsProvider with ChangeNotifier {
  final FirebaseFirestore firestore;
  late final CollectionReference _col;
  final List<PromotionRequestModel> _requests = [];

  /// Collection used to store promotion requests. Assumption: collection
  /// named `promotions_requests` (can be changed if project uses another).
  PromotionsProvider({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance {
    _col = this.firestore.collection('promotions_requests');
    // cargar las solicitudes existentes (no await en constructor)
    fetchRequests();
  }

  List<PromotionRequestModel> get requests => List.unmodifiable(_requests);

  /// Añade localmente (inmediato) y persiste en Firestore en background.
  void addRequest(PromotionRequestModel req) {
    // id temporal hasta que Firestore devuelva el id real
    req.id = DateTime.now().millisecondsSinceEpoch.toString();
    _requests.insert(0, req);
    notifyListeners();

    // Persistir de forma asíncrona
    _saveRequest(req);
  }

  Future<void> _saveRequest(PromotionRequestModel req) async {
    try {
      final createdAt = req.createdAt;
      final data = <String, dynamic>{
        'title': req.title,
        'description': req.description,
        'type': req.type,
        'contact': req.contact,
        'eventDate': req.eventDate != null
            ? Timestamp.fromDate(req.eventDate!)
            : null,
        'status': req.status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

      final docRef = await _col.add(data);

      // Actualizar id local si cambió
      final idx = _requests.indexWhere((r) => r.id == req.id);
      if (idx >= 0) {
        _requests[idx].id = docRef.id;
        notifyListeners();
      }
    } catch (e, st) {
      // No lanzar; mantener la solicitud local y loguear para debugging
      debugPrint('PromotionsProvider._saveRequest failed: $e\n$st');
    }
  }

  /// Carga todas las solicitudes desde Firestore y actualiza la lista local.
  Future<void> fetchRequests() async {
    try {
      final q = await _col.orderBy('createdAt', descending: true).get();
      _requests.clear();
      for (final doc in q.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final eventDate = d['eventDate'] != null && d['eventDate'] is Timestamp
            ? (d['eventDate'] as Timestamp).toDate()
            : null;
        final createdAt = d['createdAt'] != null && d['createdAt'] is Timestamp
            ? (d['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        final model = PromotionRequestModel(
          id: doc.id,
          title: d['title'] ?? '',
          description: d['description'] ?? '',
          type: d['type'] ?? 'anuncio',
          contact: d['contact'],
          eventDate: eventDate,
          status: d['status'] ?? 'pending',
          createdAt: createdAt,
        );
        _requests.add(model);
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('PromotionsProvider.fetchRequests failed: $e\n$st');
    }
  }

  /// Marca como aprobada en local y en Firestore (si existe el documento).
  Future<bool> approve(String id) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'approved';
      notifyListeners();
    }

    try {
      await _col.doc(id).update({'status': 'approved'});
      return true;
    } catch (e, st) {
      debugPrint('PromotionsProvider.approve failed: $e\n$st');
      return false;
    }
  }

  /// Marca como rechazada en local y en Firestore (si existe el documento).
  Future<bool> reject(String id) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'rejected';
      notifyListeners();
    }

    try {
      await _col.doc(id).update({'status': 'rejected'});
      return true;
    } catch (e, st) {
      debugPrint('PromotionsProvider.reject failed: $e\n$st');
      return false;
    }
  }
}
