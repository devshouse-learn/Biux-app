enum AgeGroup { underage, minor, adult }

class AgeVerificationEntity {
  final DateTime birthDate;
  final AgeGroup ageGroup;
  final int age;

  AgeVerificationEntity({
    required this.birthDate,
    required this.ageGroup,
    required this.age,
  });

  static AgeVerificationEntity fromBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    AgeGroup group;
    if (age < 13) {
      group = AgeGroup.underage;
    } else if (age < 18) {
      group = AgeGroup.minor;
    } else {
      group = AgeGroup.adult;
    }
    return AgeVerificationEntity(birthDate: birthDate, ageGroup: group, age: age);
  }
}
