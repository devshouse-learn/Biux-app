class CityModel {
  final String id;
  final String name;
  final String department;
  final bool isCapital;
  final int priority; // Para ordenamiento (Ibagué siempre será 0)

  CityModel({
    required this.id,
    required this.name,
    required this.department,
    this.isCapital = false,
    this.priority = 999,
  });

  factory CityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CityModel(
      id: id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      isCapital: data['isCapital'] ?? false,
      priority: data['priority'] ?? 999,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'department': department,
      'isCapital': isCapital,
      'priority': priority,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
