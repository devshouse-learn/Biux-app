
class EmergencyContactEntity {
  final String id;
  final String name;
  final String phone;
  final String? relationship;

  const EmergencyContactEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };

  factory EmergencyContactEntity.fromMap(Map<String, dynamic> map) {
    return EmergencyContactEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'],
    );
  }
}
