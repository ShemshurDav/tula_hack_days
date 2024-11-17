class HealthMetrics {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final Map<String, dynamic> values;
  final dynamic userProfile;

  bool get hasWarning {
    for (var entry in values.entries) {
      final value = entry.value.toString();
      final numValue = double.tryParse(value);
      
      if (numValue == null) {
        if (entry.key == 'Давление') {
          final parts = value.split('/');
          if (parts.length == 2) {
            final systolic = double.tryParse(parts[0]);
            final diastolic = double.tryParse(parts[1]);
            if (systolic != null && diastolic != null) {
              if (systolic >= 140 || diastolic >= 90 || 
                  systolic <= 90 || diastolic <= 60) {
                return true;
              }
            }
          }
        }
        continue;
      }

      switch (entry.key) {
        case 'Пульс':
          if (numValue >= 100 || numValue <= 50) return true;
          break;
        case 'Температура':
          if (numValue >= 37.5 || numValue <= 36.0) return true;
          break;
        case 'Уровень сахара':
          if (numValue >= 6.1 || numValue <= 3.3) return true;
          break;
        case 'Сатурация':
          if (numValue <= 95) return true;
          break;
        case 'Холестерин':
          if (numValue >= 5.2) return true;
          break;
      }
    }
    return false;
  }

  const HealthMetrics({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.values,
    this.userProfile,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'values': values,
      'userProfile': userProfile,
    };
  }
} 