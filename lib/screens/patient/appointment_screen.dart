import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../providers/medical_provider.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDoctor;
  String? _selectedSpecialty;
  final TextEditingController _commentController = TextEditingController();
  
  final List<String> _specialties = [
    'Терапевт',
    'Кардиолог',
    'Невролог',
    'Эндокринолог',
    'Гастроэнтеролог',
  ];
  
  final Map<String, List<String>> _doctors = {
    'Терапевт': ['Иванов И.И.', 'Петров П.П.'],
    'Кардиолог': ['Сидоров С.С.', 'Козлов К.К.'],
    'Невролог': ['Николаев Н.Н.', 'Морозов М.М.'],
    'Эндокринолог': ['Васильев В.В.', 'Алексеев А.А.'],
    'Гастроэнтеролог': ['Григорьев Г.Г.', 'Дмитриев Д.Д.'],
  };
  
  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00',
    '11:30', '12:00', '14:00', '14:30', '15:00',
    '15:30', '16:00', '16:30', '17:00'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на приём'),
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
                  'Выберите специальность',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value;
                      _selectedDoctor = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedSpecialty != null) GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите врача',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDoctor,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: _doctors[_selectedSpecialty]!.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text(doctor),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDoctor = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_selectedDoctor != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите дату',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(_selectedDate == null 
                      ? 'Нажмите, чтобы выбрать дату'
                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                          _selectedTime = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          if (_selectedDate != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите время',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      return ChoiceChip(
                        label: Text(time),
                        selected: _selectedTime == time,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTime = selected ? time : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          if (_selectedTime != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Комментарий к записи',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Опишите причину обращения...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_selectedDoctor != null && _selectedDate != null && _selectedTime != null) {
                  // Парсим время
                  final timeParts = _selectedTime!.split(':');
                  final dateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    int.parse(timeParts[0]),
                    int.parse(timeParts[1]),
                  );

                  // Создаем новую запись
                  final appointment = Appointment(
                    doctorName: _selectedDoctor!,
                    specialty: _selectedSpecialty!,
                    dateTime: dateTime,
                    comment: _commentController.text,
                  );

                  // Сохраняем запись
                  context.read<MedicalProvider>().addAppointment(appointment);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Запись успешно создана'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Записаться на приём'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
} 