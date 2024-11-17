import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../widgets/glass_container.dart';
import 'package:intl/intl.dart';

class MedicationScheduleScreen extends StatelessWidget {
  const MedicationScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('График приема лекарств'),
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, medical, _) {
          final medications = medical.getPatientMedications(
            context.read<AuthProvider>().userId,
          );

          if (medications.isEmpty) {
            return const Center(
              child: Text('График приема лекарств пока не назначен'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Дозировка: ${medication.dosage}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Время приёма: ${medication.schedule.map((time) => 
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        ).join(', ')}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (medication.instructions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Инструкции: ${medication.instructions}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (medication.startDate != DateTime(0)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Начало приёма: ${DateFormat('dd.MM.yyyy').format(medication.startDate)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (medication.endDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Окончание приёма: ${DateFormat('dd.MM.yyyy').format(medication.endDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 