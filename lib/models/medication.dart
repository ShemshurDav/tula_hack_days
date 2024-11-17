import 'package:flutter/material.dart' show TimeOfDay;

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<TimeOfDay> schedule;
  final String instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.instructions,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      schedule: (json['schedule'] as List)
          .map((time) => TimeOfDay(
                hour: int.parse(time.split(':')[0]),
                minute: int.parse(time.split(':')[1]),
              ))
          .toList(),
      instructions: json['instructions'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'schedule': schedule
          .map((time) => '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}')
          .toList(),
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
} 