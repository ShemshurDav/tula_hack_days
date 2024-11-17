import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import 'patient_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
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
                  'Сегодня',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _NotificationTile(
                  title: 'Критические показатели',
                  message: 'Пациент Иванов П.С.: АД 180/100',
                  time: '30 минут назад',
                  priority: 'critical',
                  patientId: '1',
                ),
                const _NotificationTile(
                  title: 'Важно: Совещание',
                  message: 'Завтра в 9:00 состоится общее собрание врачей',
                  time: '2 часа назад',
                  priority: 'high',
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
                  'Вчера',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _NotificationTile(
                  title: 'Новая запись',
                  message: 'Пациент Петрова А.И. записалась на приём',
                  time: '1 день назад',
                  priority: 'medium',
                ),
                const _NotificationTile(
                  title: 'Результаты анализов',
                  message: 'Доступны результаты анализов пациента Сидоров К.М.',
                  time: '1 день назад',
                  priority: 'medium',
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
                  'Ранее',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _NotificationTile(
                  title: 'Обновление графика',
                  message: 'Изменения в расписании на следующую неделю',
                  time: '3 дня назад',
                  priority: 'low',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String priority;
  final String? patientId;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.priority,
    this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color getPriorityColor() {
      switch (priority) {
        case 'critical':
          return colorScheme.error;
        case 'high':
          return colorScheme.error.withOpacity(0.7);
        case 'medium':
          return colorScheme.primary;
        default:
          return colorScheme.outline;
      }
    }

    IconData getPriorityIcon() {
      switch (priority) {
        case 'critical':
          return Icons.warning;
        case 'high':
          return Icons.priority_high;
        case 'medium':
          return Icons.info;
        default:
          return Icons.notifications;
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: getPriorityColor().withOpacity(0.1),
        child: Icon(
          getPriorityIcon(),
          color: getPriorityColor(),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(message),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: patientId != null ? () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailsScreen(
              patientId: patientId!,
              patientName: message.split(':')[0].replaceAll('Пациент ', ''),
            ),
          ),
        );
      } : null,
    );
  }
} 