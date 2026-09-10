class Medication {
  final String name;
  final String? dose;
  final String? frequency;

  const Medication({
    required this.name,
    this.dose,
    this.frequency,
  });

  Medication copyWith({
    String? name,
    String? dose,
    String? frequency,
  }) {
    return Medication(
      name: name ?? this.name,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'frequency': frequency,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String,
      dose: json['dose'] as String?,
      frequency: json['frequency'] as String?,
    );
  }
}
