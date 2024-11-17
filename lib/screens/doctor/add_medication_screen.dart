import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medical_provider.dart';
import '../../models/medication.dart';
import '../../widgets/glass_container.dart';

class AddMedicationScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddMedicationScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<TimeOfDay> _schedule = [];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (!_schedule.contains(picked)) {
          _schedule.add(picked);
          _schedule.sort((a, b) {
            final aMinutes = a.hour * 60 + a.minute;
            final bMinutes = b.hour * 60 + b.minute;
            return aMinutes.compareTo(bMinutes);
          });
        }
      });
    }
  }

  void _removeTime(TimeOfDay time) {
    setState(() {
      _schedule.remove(time);
    });
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate() && _schedule.isNotEmpty) {
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        schedule: _schedule,
        startDate: _startDate,
        endDate: _endDate,
        instructions: _instructionsController.text,
        isActive: true,
      );

      context.read<MedicalProvider>().addMedicationForPatient(
        widget.patientId,
        medication,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лекарство успешно назначено')),
      );
      Navigator.pop(context);
    } else if (_schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте время приёма лекарства')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Назначить лекарство'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Пациент: ${widget.patientName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название лекарства',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите название лекарства';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Дозировка',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите дозировку';
                      }
                      return null;
                    },
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
                    'Расписание приёма',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text('Начало: ${_startDate.toString().split(' ')[0]}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'Конец: ${_endDate?.toString().split(' ')[0] ?? 'Не указано'}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: const Icon(Icons.access_time),
                          label: const Text('Добавить время приёма'),
                        ),
                      ),
                    ],
                  ),
                  if (_schedule.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _schedule.map((time) {
                        return Chip(
                          label: Text(
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          ),
                          onDeleted: () => _removeTime(time),
                        );
                      }).toList(),
                    ),
                  ],
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
                    'Дополнительные инструкции',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Инструкции по приёму',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMedication,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Назначить лекарство'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 