import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:biux/features/promotions/data/models/promotion_request_model.dart';

class PromotionsProvider with ChangeNotifier {
  final FirebaseFirestore firestore;
  late final CollectionReference _col;
  late final CollectionReference _promotersCol;
  final List<PromotionRequestModel> _requests = [];
  final Set<String> _verifiedPromoters = {};

  PromotionsProvider({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance {
    _col = this.firestore.collection('promotions_requests');
    _promotersCol = this.firestore.collection('verified_promoters');
    fetchRequests();
    _loadVerifiedPromoters();
  }

  List<PromotionRequestModel> get requests => List.unmodifiable(_requests);
  List<PromotionRequestModel> get approvedBusinesses => _requests
      .where((r) => r.type == 'negocio' && r.status == 'approved')
      .toList();
  List<PromotionRequestModel> get approvedEvents => _requests
      .where((r) => r.type == 'evento' && r.status == 'approved')
      .toList();
  List<PromotionRequestModel> get pendingRequests =>
      _requests.where((r) => r.status == 'pending').toList();

  bool isVerifiedPromoter(String uid) => _verifiedPromoters.contains(uid);

  Future<void> _loadVerifiedPromoters() async {
    try {
      final q = await _promotersCol.get();
      _verifiedPromoters.clear();
      for (final doc in q.docs) {
        _verifiedPromoters.add(doc.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading verified promoters: \$e');
    }
  }

  /// Solicitar ser promotor verificado
  Future<bool> requestPromoterStatus(
    String uid,
    String name,
    String businessName,
    String businessDescription,
  ) async {
    try {
      await firestore.collection('promoter_requests').doc(uid).set({
        'uid': uid,
        'name': name,
        'businessName': businessName,
        'businessDescription': businessDescription,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error requesting promoter status: \$e');
      return false;
    }
  }

  /// Admin: aprobar promotor
  Future<bool> approvePromoter(String uid) async {
    try {
      await _promotersCol.doc(uid).set({
        'verifiedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      _verifiedPromoters.add(uid);
      notifyListeners();

      // Actualizar estado de la solicitud
      await firestore.collection('promoter_requests').doc(uid).update({
        'status': 'approved',
      });
      return true;
    } catch (e) {
      debugPrint('Error approving promoter: \$e');
      return false;
    }
  }

  /// Admin: revocar promotor
  Future<bool> revokePromoter(String uid) async {
    try {
      await _promotersCol.doc(uid).delete();
      _verifiedPromoters.remove(uid);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error revoking promoter: \$e');
      return false;
    }
  }

  /// Crear solicitud de publicacion
  void addRequest(PromotionRequestModel req) {
    req.id = DateTime.now().millisecondsSinceEpoch.toString();
    // Si es promotor verificado, aprobar automaticamente
    if (_verifiedPromoters.contains(req.ownerUid)) {
      req.status = 'approved';
      req.isPromoter = true;
    }
    _requests.insert(0, req);
    notifyListeners();
    _saveRequest(req);
  }

  Future<void> _saveRequest(PromotionRequestModel req) async {
    try {
      final data = <String, dynamic>{
        'title': req.title,
        'description': req.description,
        'type': req.type,
        'contact': req.contact,
        'imageUrl': req.imageUrl,
        'location': req.location,
        'eventDate': req.eventDate != null
            ? Timestamp.fromDate(req.eventDate!)
            : null,
        'eventTime': req.eventTime,
        'maxAttendees': req.maxAttendees,
        'attendees': req.attendees,
        'status': req.status,
        'ownerUid': req.ownerUid,
        'ownerName': req.ownerName,
        'isPromoter': req.isPromoter,
        'createdAt': Timestamp.fromDate(req.createdAt),
      };

      final docRef = await _col.add(data);
      final idx = _requests.indexWhere((r) => r.id == req.id);
      if (idx >= 0) {
        _requests[idx].id = docRef.id;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('PromotionsProvider._saveRequest failed: \$e\n\$st');
    }
  }

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

        final attendeesList = d['attendees'] is List
            ? List<String>.from(d['attendees'])
            : <String>[];

        final model = PromotionRequestModel(
          id: doc.id,
          title: d['title'] ?? '',
          description: d['description'] ?? '',
          type: d['type'] ?? 'negocio',
          contact: d['contact'],
          imageUrl: d['imageUrl'],
          location: d['location'],
          eventDate: eventDate,
          eventTime: d['eventTime'],
          maxAttendees: d['maxAttendees'],
          attendees: attendeesList,
          status: d['status'] ?? 'pending',
          ownerUid: d['ownerUid'] ?? '',
          ownerName: d['ownerName'] ?? '',
          isPromoter: d['isPromoter'] ?? false,
          createdAt: createdAt,
        );
        _requests.add(model);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('PromotionsProvider.fetchRequests failed: \$e\n\$st');
    }
  }

  /// Registrarse a un evento
  Future<bool> registerToEvent(String eventId, String userId) async {
    final idx = _requests.indexWhere((r) => r.id == eventId);
    if (idx < 0) return false;

    final event = _requests[idx];
    if (event.attendees.contains(userId)) return false;
    if (event.isFull) return false;

    event.attendees.add(userId);
    notifyListeners();

    try {
      await _col.doc(eventId).update({
        'attendees': FieldValue.arrayUnion([userId]),
      });
      return true;
    } catch (e) {
      event.attendees.remove(userId);
      notifyListeners();
      debugPrint('Error registering to event: \$e');
      return false;
    }
  }

  /// Cancelar registro a un evento
  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    final idx = _requests.indexWhere((r) => r.id == eventId);
    if (idx < 0) return false;

    final event = _requests[idx];
    if (!event.attendees.contains(userId)) return false;

    event.attendees.remove(userId);
    notifyListeners();

    try {
      await _col.doc(eventId).update({
        'attendees': FieldValue.arrayRemove([userId]),
      });
      return true;
    } catch (e) {
      event.attendees.add(userId);
      notifyListeners();
      debugPrint('Error unregistering from event: \$e');
      return false;
    }
  }

  Future<bool> approve(String id) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'approved';
      notifyListeners();
    }
    try {
      await _col.doc(id).update({'status': 'approved'});
      return true;
    } catch (e) {
      debugPrint('PromotionsProvider.approve failed: \$e');
      return false;
    }
  }

  Future<bool> reject(String id) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _requests[i].status = 'rejected';
      notifyListeners();
    }
    try {
      await _col.doc(id).update({'status': 'rejected'});
      return true;
    } catch (e) {
      debugPrint('PromotionsProvider.reject failed: \$e');
      return false;
    }
  }
}
