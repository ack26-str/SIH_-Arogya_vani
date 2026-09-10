class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String? email;
  final String preferredLanguage;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email,
    required this.preferredLanguage,
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? preferredLanguage,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }
}
