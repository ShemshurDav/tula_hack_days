class HealthRecord {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final Map<String, dynamic> indicators;
  final bool isNormal;

  HealthRecord({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.indicators,
    required this.isNormal,
  });
} 