class LabResult {
  final String testName;
  final String resultValue;
  final String? date;

  const LabResult({
    required this.testName,
    required this.resultValue,
    this.date,
  });

  LabResult copyWith({
    String? testName,
    String? resultValue,
    String? date,
  }) {
    return LabResult(
      testName: testName ?? this.testName,
      resultValue: resultValue ?? this.resultValue,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_name': testName,
      'result_value': resultValue,
      'date': date,
    };
  }

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      testName: json['test_name'] as String? ?? 'Unknown',
      resultValue: json['result_value'] as String? ?? 'Unknown',
      date: json['date'] as String?,
    );
  }
}
