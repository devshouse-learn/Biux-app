class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String phoneNumber;
  final bool isDeleting;
  final DateTime? deletionRequestDate;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    required this.phoneNumber,
    this.isDeleting = false,
    this.deletionRequestDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isDeleting': isDeleting,
      'deletionRequestDate': deletionRequestDate?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      isDeleting: map['isDeleting'] ?? false,
      deletionRequestDate: map['deletionRequestDate'] != null
          ? DateTime.parse(map['deletionRequestDate'])
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    bool? isDeleting,
    DateTime? deletionRequestDate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDeleting: isDeleting ?? this.isDeleting,
      deletionRequestDate: deletionRequestDate ?? this.deletionRequestDate,
    );
  }
}
