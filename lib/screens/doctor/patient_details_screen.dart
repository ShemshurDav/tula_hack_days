import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_container.dart';
import '../../providers/medical_provider.dart';
import 'add_medication_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patientName),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMedicationScreen(
                    patientId: patientId,
                    patientName: patientName,
                  ),
                ),
              );
            },
            tooltip: 'Назначить лекарство',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Основная информация',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Возраст'),
                  subtitle: Text('45 лет'),
                ),
                const ListTile(
                  leading: Icon(Icons.medical_information),
                  title: Text('Группа крови'),
                  subtitle: Text('A(II) Rh+'),
                ),
                const ListTile(
                  leading: Icon(Icons.warning_amber),
                  title: Text('Аллергии'),
                  subtitle: Text('Пенициллин, Ибупрофен'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'История приёмов',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Последний приём'),
                  subtitle: Text('01.03.2024 - Плановый осмотр'),
                ),
                // Здесь можно добавить больше информации о пациенте
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Текущие назначения',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer<MedicalProvider>(
                  builder: (context, medical, _) {
                    final medications = medical.getPatientMedications(patientId);
                    
                    if (medications.isEmpty) {
                      return const Text('Нет активных назначений');
                    }
                    
                    return Column(
                      children: medications
                          .where((med) => med.isActive)
                          .map((medication) => Card(
                                child: ListTile(
                                  title: Text(medication.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(medication.dosage),
                                      Text(
                                        'Время приёма: ${medication.schedule.map((t) => 
                                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
                                        ).join(', ')}',
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 