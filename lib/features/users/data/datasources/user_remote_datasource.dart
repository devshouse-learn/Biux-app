import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/users/data/models/user_model.dart';

// Remote Data Source Interface for Users
abstract class UserRemoteDataSource {
  Future<UserModel?> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> createUser(Map<String, dynamic> userData);
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}

// Implementation of Remote Data Source using Firestore
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      return UserModel.fromMap({
        'uid': doc.id,
        'name': data['fullName'] ?? data['name'],
        'email': data['email'],
        'photoUrl': data['photo'] ?? data['photoUrl'],
        'phoneNumber': data['phoneNumber'] ?? '',
        'username': data['userName'] ?? data['username'],
        'isDeleting': data['isDeleting'] ?? false,
        'deletionRequestDate': data['deletionRequestDate'],
      });
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({
          'uid': doc.id,
          'name': data['fullName'] ?? data['name'],
          'email': data['email'],
          'photoUrl': data['photo'] ?? data['photoUrl'],
          'phoneNumber': data['phoneNumber'] ?? '',
          'username': data['userName'] ?? data['username'],
          'isDeleting': data['isDeleting'] ?? false,
          'deletionRequestDate': data['deletionRequestDate'],
        });
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final docRef = await _firestore.collection('usuarios').add(userData);
      final doc = await docRef.get();
      final data = doc.data()!;
      return UserModel.fromMap({
        'uid': doc.id,
        'name': data['fullName'] ?? data['name'],
        'email': data['email'],
        'photoUrl': data['photo'] ?? data['photoUrl'],
        'phoneNumber': data['phoneNumber'] ?? '',
        'username': data['userName'] ?? data['username'],
        'isDeleting': data['isDeleting'] ?? false,
        'deletionRequestDate': data['deletionRequestDate'],
      });
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('usuarios').doc(id).update(userData);
      final doc = await _firestore.collection('usuarios').doc(id).get();
      final data = doc.data()!;
      return UserModel.fromMap({
        'uid': doc.id,
        'name': data['fullName'] ?? data['name'],
        'email': data['email'],
        'photoUrl': data['photo'] ?? data['photoUrl'],
        'phoneNumber': data['phoneNumber'] ?? '',
        'username': data['userName'] ?? data['username'],
        'isDeleting': data['isDeleting'] ?? false,
        'deletionRequestDate': data['deletionRequestDate'],
      });
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('usuarios').doc(id).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
