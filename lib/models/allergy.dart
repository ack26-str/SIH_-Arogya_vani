class Allergy {
  final String allergen;
  final String? reaction;

  const Allergy({
    required this.allergen,
    this.reaction,
  });

  Allergy copyWith({
    String? allergen,
    String? reaction,
  }) {
    return Allergy(
      allergen: allergen ?? this.allergen,
      reaction: reaction ?? this.reaction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergen': allergen,
      'reaction': reaction,
    };
  }

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      allergen: json['allergen'] as String? ?? 'Unknown',
      reaction: json['reaction'] as String?,
    );
  }
}
