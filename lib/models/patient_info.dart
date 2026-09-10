class PatientInfo {
  final String? age;
  final String? gender;
  final String? weight;

  const PatientInfo({
    this.age,
    this.gender,
    this.weight,
  });

  PatientInfo copyWith({
    String? age,
    String? gender,
    String? weight,
  }) {
    return PatientInfo(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'weight': weight,
    };
  }

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      weight: json['weight'] as String?,
    );
  }
}
