import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/medical_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_container.dart';
import 'patient/health_metrics_screen.dart';
import 'patient/medication_schedule_screen.dart';
import 'patient/health_metrics_chart_screen.dart';
import 'patient/user_profile_screen.dart';
import 'patient/settings_screen.dart';
import 'patient/appointment_screen.dart';
import 'package:intl/intl.dart';
import 'patient/appointment_details_screen.dart';
import 'patient/chat_screen.dart';
import 'patient/ai_assistant_chat_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final _pageController = PageController();
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<({IconData icon, String title, Widget screen})> _screens = [
    (
      icon: Icons.home,
      title: 'Главная',
      screen: const _HomeScreen(),
    ),
    (
      icon: Icons.calendar_month,
      title: 'Записи',
      screen: const _AppointmentsScreen(),
    ),
    (
      icon: Icons.message,
      title: 'Чат',
      screen: const _ChatScreen(),
    ),
    (
      icon: Icons.person,
      title: 'Профиль',
      screen: const _ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    );
    _fabController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            width: 200,
            child: Text(
              _screens[_selectedIndex].title,
              key: ValueKey(_selectedIndex),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final userId = context.read<AuthProvider>().userId;
              final profileLink = 'https://happyhub.app/profile/$userId';
              
              try {
                // Сохраняем ScaffoldMessenger до асинхронной операции
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                // Копируем в буфер обмена
                await Clipboard.setData(ClipboardData(text: profileLink));
                
                // Проверяем, что виджет все еще в дереве
                if (!mounted) return;
                
                // Используем сохраненный ScaffoldMessenger
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Ссылка на профиль скопирована в буфер обмена'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                // Создаем новый ScaffoldMessenger после проверки mounted
                final errorMessage = 'Ошибка при копировании: $e';
                final newScaffoldMessenger = ScaffoldMessenger.of(context);
                
                newScaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
          _fabController.forward(from: 0);
        },
        itemCount: _screens.length,
        itemBuilder: (context, index) => _screens[index].screen,
      ),
      floatingActionButton: _selectedIndex == 0
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthMetricsScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Ввести показатели'),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: _screens.map((screen) {
          return NavigationDestination(
            icon: Icon(screen.icon),
            label: screen.title,
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications),
            const SizedBox(width: 8),
            const Text('Уведомления'),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              _NotificationItem(
                icon: Icons.medical_services,
                title: 'Напоминание о приёме',
                message: 'Завтра в 15:00 приём у терапевта',
                time: '5 минут назад',
                isUnread: true,
              ),
              Divider(),
              _NotificationItem(
                icon: Icons.medication,
                title: 'Приём лекарств',
                message: 'Пора принять Ибупрофен',
                time: '1 чс назад',
                isUnread: true,
              ),
              Divider(),
              _NotificationItem(
                icon: Icons.favorite,
                title: 'Показатели здоровья',
                message: 'Пульс в номе: 72 уд/мин',
                time: '3 часа назад',
              ),
              Divider(),
              _NotificationItem(
                icon: Icons.message,
                title: 'Новое сообщение',
                message: 'Доктор ответил на ваш вопрос',
                time: '5 часов назад',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, MedicalProvider>(
      builder: (context, settings, medical, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Динамика показателей',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DropdownButton<String>(
                        value: settings.defaultMetric,
                        items: settings.availableMetrics
                            .map((metric) => DropdownMenuItem(
                                  value: metric,
                                  child: Text(metric),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            settings.setDefaultMetric(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: HealthMetricsChartScreen(
                      metricName: settings.defaultMetricEn,
                    ),
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
                    'График приема лекарств',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Consumer<MedicalProvider>(
                    builder: (context, medical, _) {
                      final userId = context.read<AuthProvider>().userId;
                      final medications = medical.getPatientMedications(userId);
                      
                      if (medications.isEmpty) {
                        return const Text('Нет активных назначений');
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...medications.take(2).map((med) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        '${med.dosage} в ${med.schedule.map((t) => 
                                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
                                        ).join(', ')}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          )),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MedicationScheduleScreen(),
                              ),
                            ),
                            child: const Text('Показать все'),
                          ),
                        ],
                      );
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
                    'Рекомендации AI',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Consumer<MedicalProvider>(
                    builder: (context, medical, _) {
                      if (medical.isLoadingAdvice) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Ассистент анализирует ваши показатели...',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: medical.lastAIAdvice
                              ?.split('\n')
                              .map((line) {
                                if (line.trim().isEmpty) {
                                  return const SizedBox(height: 8);
                                }
                                
                                final formattedText = _formatText(line, Theme.of(context));
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: formattedText,
                                );
                              })
                              .toList() ?? 
                            [
                              Text(
                                'Нт последних рекомендаций',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _formatText(String text, ThemeData theme) {
    if (text.startsWith('**') && text.endsWith('**')) {
      return Text(
        text.substring(2, text.length - 2),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (text.contains('**')) {
      final spans = <TextSpan>[];
      final parts = text.split('**');
      bool isBold = false;

      for (final part in parts) {
        if (part.isNotEmpty) {
          spans.add(TextSpan(
            text: part,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ));
        }
        isBold = !isBold;
      }

      return RichText(
        text: TextSpan(children: spans),
      );
    }

    return Text(
      text,
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _AppointmentsScreen extends StatelessWidget {
  const _AppointmentsScreen();

  Future<bool?> _showCancelDialog(BuildContext context, Appointment appointment) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отмена записи'),
        content: Text(
          'Вы уверены, что хотите отменить запись к ${appointment.specialty.toLowerCase()}у '
          '(${appointment.doctorName}) на '
          '${DateFormat('d MMMM в HH:mm', 'ru').format(appointment.dateTime)}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () {
              context.read<MedicalProvider>().cancelAppointment(appointment.dateTime);
              Navigator.pop(dialogContext, true);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Запись отменена'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Отменить запись'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Записаться на приём',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Новая запись'),
                subtitle: const Text('Запланируйте визит к врачу'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentScreen(),
                  ),
                ),
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
                'Ближайшие приёмы',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<MedicalProvider>(
                builder: (context, medical, _) {
                  final appointments = medical.getUpcomingAppointments();
                  
                  if (appointments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Нет запланированных прёмов'),
                    );
                  }

                  return Column(
                    children: appointments.map((appointment) {
                      return Dismissible(
                        key: ValueKey(appointment.dateTime),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _showCancelDialog(context, appointment),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Theme.of(context).colorScheme.error,
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(appointment.specialty),
                          subtitle: Text(
                            '${appointment.doctorName}\n'
                            '${DateFormat('d MMMM, HH:mm', 'ru').format(appointment.dateTime)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () => _showCancelDialog(context, appointment),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentDetailsScreen(
                                  appointment: appointment,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
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
                'Прошедшие приёмы',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<MedicalProvider>(
                builder: (context, medical, _) {
                  final appointments = medical.getPastAppointments();
                  
                  if (appointments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Нет прошедших приёмов'),
                    );
                  }

                  return Column(
                    children: appointments.map((appointment) {
                      return ListTile(
                        leading: const Icon(Icons.event_available),
                        title: Text(appointment.specialty),
                        subtitle: Text(
                          '${appointment.doctorName}\n'
                          '${DateFormat('d MMMM, HH:mm', 'ru').format(appointment.dateTime)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetailsScreen(
                                appointment: appointment,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatScreen extends StatelessWidget {
  const _ChatScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Чаты',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: const Text('AI Ассистент'),
                subtitle: const Text('Задайте вопрос о здоровье'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIAssistantChatScreen(),
                  ),
                ),
              ),
              const Divider(),
              Consumer<MedicalProvider>(
                builder: (context, medical, _) {
                  final appointments = medical.getUpcomingAppointments();
                  if (appointments.isEmpty) {
                    return const ListTile(
                      leading: Icon(Icons.message_outlined),
                      title: Text('У вас нет активных записей к врачу'),
                      subtitle: Text('Запишитесь на приём, чтобы начать чат'),
                    );
                  }
                  
                  return Column(
                    children: appointments.map((appointment) => ListTile(
                      leading: const Icon(Icons.message_outlined),
                      title: Text(appointment.doctorName),
                      subtitle: Text(appointment.specialty),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            doctorName: appointment.doctorName,
                            specialty: appointment.specialty,
                          ),
                        ),
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final userName = context.read<AuthProvider>().userName;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Consumer<AuthProvider>(
          builder: (context, auth, _) => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
              image: auth.photoUrl != null
                  ? DecorationImage(
                      image: AssetImage(auth.photoUrl!),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: auth.photoUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.medical_information),
                title: const Text('Медицинский профиль'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Настройки'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Помощь'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Помощь'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Для получения помощи вы можете:\n\n'
                        '1. Обратиться в техподдержку\n'
                        '2. Посмотреть обучающие материалы\n'
                        '3. Задать вопрос в чате с AI-ассистентм\n\n'
                        'Телефон поддержки: 8-800-123-45-67\n'
                        'Email: support@happyhub.ru'
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть'),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('О приложении'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('О приложении'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Assistant - Ваш персональный медицинский помощник\n\n'
                        'Версия: 1.0.0\n\n'
                        'Разработано командой HappyHub\n'
                        '© 2024 Все права защищены\n\n'
                        'Приложение предназначено для:\n'
                        '• Записи к врачу\n'
                        '• Отслеживания показателей здоровья\n'
                        '• Контроля приема лекарств\n'
                        '• Консультаций с AI-ассистентом'
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isUnread 
            ? colorScheme.primary 
            : colorScheme.surfaceContainerHighest,
        child: Icon(
          icon,
          color: isUnread 
              ? colorScheme.onPrimary 
              : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        switch (icon) {
          case Icons.medical_services:
            Navigator.pop(context);
            Navigator.pushNamed(context, '/appointments');
            break;
          case Icons.medication:
            Navigator.pop(context);
            Navigator.pushNamed(context, '/medications');
            break;
          case Icons.favorite:
            Navigator.pop(context);
            Navigator.pushNamed(context, '/health-metrics');
            break;
          case Icons.message:
            Navigator.pop(context);
            Navigator.pushNamed(context, '/chat');
            break;
        }
      },
    );
  }
} 