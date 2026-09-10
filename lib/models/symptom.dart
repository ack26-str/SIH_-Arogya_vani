class Symptom {
  final String name;
  final String? duration;
  final String? severity;

  const Symptom({
    required this.name,
    this.duration,
    this.severity,
  });

  Symptom copyWith({
    String? name,
    String? duration,
    String? severity,
  }) {
    return Symptom(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      severity: severity ?? this.severity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'severity': severity,
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'] as String,
      duration: json['duration'] as String?,
      severity: json['severity'] as String?,
    );
  }
}
