import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import 'doctor/patient_details_screen.dart';
import 'doctor/notifications_screen.dart';
import 'doctor/chat_screen.dart';
import 'patient/ai_assistant_chat_screen.dart';
import '../providers/medical_provider.dart';
import 'doctor/settings_screen.dart';
import 'doctor/help_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  final _pageController = PageController();

  final List<({IconData icon, String title, Widget screen})> _screens = const [
    (
      icon: Icons.people,
      title: 'Пациенты',
      screen: _PatientsScreen(),
    ),
    (
      icon: Icons.calendar_today,
      title: 'Расписание',
      screen: _ScheduleScreen(),
    ),
    (
      icon: Icons.chat,
      title: 'Чаты',
      screen: _ChatsScreen(),
    ),
    (
      icon: Icons.person,
      title: 'Профиль',
      screen: _ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userName = context.read<AuthProvider>().userName;
    const hasUnreadNotifications = true; // Изменено с final на const

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_screens[_selectedIndex].title),
            Text(
              userName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotificationsDialog(context),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _screens.map((screen) => screen.screen).toList(),
      ),
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

  void _showNotificationsDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _PatientsScreen extends StatelessWidget {
  const _PatientsScreen();

  @override
  Widget build(BuildContext context) {
    final patients = <Map<String, String>>[
      {
        'id': '1',
        'name': 'Иванов Петр Сергеевич',
        'lastVisit': '01.03.2024',
      },
      {
        'id': '2',
        'name': 'Петрова Анна Ивановна',
        'lastVisit': '28.02.2024',
      },
      {
        'id': '3',
        'name': 'Сидоров Иван Петрович',
        'lastVisit': '25.02.2024',
      },
      {
        'id': '4',
        'name': 'Козлова Мария Андреевна',
        'lastVisit': '20.02.2024',
      },
      {
        'id': '5',
        'name': 'Морозов Андрей Иванович',
        'lastVisit': '15.02.2024',
      },
      {
        'id': '6',
        'name': 'Николаева Елена Сергеевна',
        'lastVisit': '10.02.2024',
      },
      {
        'id': '7',
        'name': 'Васильев Сергей Петрович',
        'lastVisit': '05.02.2024',
      },
      {
        'id': '8',
        'name': 'Кузнецова Ольга Андреевна',
        'lastVisit': '01.02.2024',
      },
      {
        'id': '9',
        'name': 'Соколов Дмитрий Иванович',
        'lastVisit': '25.01.2024',
      },
      {
        'id': '10',
        'name': 'Попова Татьяна Сергеевна',
        'lastVisit': '20.01.2024',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.people_outline, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Всего пациентов:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                          ),
                          Text('10'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Приёмов сегодня:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                          ),
                          Text('8'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Статистика за неделю',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _StatisticCard(
                      icon: Icons.people,
                      title: 'Новых пациентов',
                      value: '5',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _StatisticCard(
                      icon: Icons.medical_services,
                      title: 'Приёмов проведено',
                      value: '32',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(
                    child: _StatisticCard(
                      icon: Icons.star,
                      title: 'Средняя оценка',
                      value: '4.8',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _StatisticCard(
                      icon: Icons.timer,
                      title: 'Среднее время приёма',
                      value: '25 мин',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Список пациентов',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...patients.map((patient) {
          final patientNumber = int.parse(patient['id']!);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  radius: 24,
                  child: Text(
                    'П$patientNumber',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                title: Text(
                  patient['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Последний визит: ${patient['lastVisit']}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailsScreen(
                        patientId: 'patient_$patientNumber',
                        patientName: patient['name']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _ChatsScreen extends StatelessWidget {
  const _ChatsScreen();

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
                'Чаты с пациентами',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const _ChatTile(
                name: 'Иванов П.С.',
                lastMessage: 'Добрый день, доктор!',
                time: '5 мин назад',
                unread: true,
                patientId: '1',
              ),
              const _ChatTile(
                name: 'Петрова А.И.',
                lastMessage: 'Спасибо за консультацию',
                time: '1 час назад',
                unread: false,
                patientId: '2',
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
                'AI Ассистент',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('Открыть чат с AI'),
                subtitle: const Text('Получите помощь в анализе данных'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIAssistantChatScreen(),
                    ),
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

class _ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final bool unread;
  final String patientId;

  const _ChatTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(lastMessage),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: Theme.of(context).textTheme.bodySmall),
          Consumer<MedicalProvider>(
            builder: (context, medical, _) {
              final unreadCount = medical.getUnreadCount(patientId);
              if (unreadCount == 0) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              patientId: patientId,
              patientName: name,
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleScreen extends StatelessWidget {
  const _ScheduleScreen();

  @override
  Widget build(BuildContext context) {
    final todayAppointments = [
      {
        'id': '1',
        'patientName': 'Иванов П.С.',
        'time': '09:00',
        'type': 'Первичный приём',
        'status': 'completed',
        'comment': 'Осмотр проведен, назначено лечение',
      },
      {
        'id': '2',
        'patientName': 'Петрова А.И.',
        'time': '10:15',
        'type': 'Повторный приём',
        'status': 'completed',
        'comment': 'Коррекция лечения',
      },
      {
        'id': '3',
        'patientName': 'Сидоров И.П.',
        'time': '11:30',
        'type': 'Консультация',
        'status': 'completed',
        'comment': 'Даны рекомендации',
      },
      {
        'id': '4',
        'patientName': 'Козлова М.А.',
        'time': '13:00',
        'type': 'Плановый осмотр',
        'status': 'upcoming',
      },
      {
        'id': '5',
        'patientName': 'Морозов А.И.',
        'time': '14:15',
        'type': 'Первичный приём',
        'status': 'upcoming',
      },
    ];

    final pastAppointments = [
      {
        'date': '17.11.2024',
        'appointments': [
          {
            'id': '101',
            'patientName': 'Васильев С.П.',
            'time': '10:00',
            'type': 'Повторный приём',
            'status': 'completed',
            'comment': 'Улучшение состояния, коррекция терапии',
          },
          {
            'id': '102',
            'patientName': 'Кузнецова О.А.',
            'time': '15:30',
            'type': 'Первичный приём',
            'status': 'completed',
            'comment': 'Назначено обследование',
          },
        ],
      },
      {
        'date': '15.11.2024',
        'appointments': [
          {
            'id': '103',
            'patientName': 'Николаева Е.С.',
            'time': '09:30',
            'type': 'Первичный приём',
            'status': 'completed',
            'comment': 'Назначено лечение',
          },
          {
            'id': '104',
            'patientName': 'Морозов А.И.',
            'time': '14:00',
            'type': 'Консультация',
            'status': 'completed',
            'comment': 'Даны рекомендации',
          },
        ],
      },
      {
        'date': '13.11.2024',
        'appointments': [
          {
            'id': '105',
            'patientName': 'Петрова А.И.',
            'time': '11:00',
            'type': 'Повторный приём',
            'status': 'completed',
            'comment': 'Положительная динамика',
          },
        ],
      },
      {
        'date': '11.11.2024',
        'appointments': [
          {
            'id': '106',
            'patientName': 'Иванов П.С.',
            'time': '10:30',
            'type': 'Консультация',
            'status': 'completed',
            'comment': 'Обсуждение результатов анализов',
          },
          {
            'id': '107',
            'patientName': 'Сидоров И.П.',
            'time': '16:00',
            'type': 'Повторный приём',
            'status': 'completed',
            'comment': 'Коррекция лечения',
          },
        ],
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Сегодня'),
              Tab(text: 'Неделя'),
              Tab(text: 'Месяц'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TodaySchedule(appointments: todayAppointments),
                _PastSchedule(
                  appointments: pastAppointments,
                  title: 'За последнюю неделю',
                ),
                _PastSchedule(
                  appointments: pastAppointments,
                  title: 'За последний месяц',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  final List<Map<String, String>> appointments;

  const _TodaySchedule({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Приёмы сегодня:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${appointments.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...appointments.map((appointment) {
          final bool isCompleted = appointment['status'] == 'completed';
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    appointment['time']!.split(':')[0],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      appointment['patientName']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) 
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Завершён',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['type']!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      appointment['time']!,
                      style: TextStyle(
                        color: isCompleted ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                                        : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (isCompleted && appointment['comment'] != null)
                      Text(
                        appointment['comment']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                trailing: isCompleted ? const Icon(Icons.check_circle, color: Colors.green) 
                                    : const Icon(Icons.chevron_right),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PastSchedule extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final String title;

  const _PastSchedule({
    required this.appointments,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...appointments.map((dayAppointments) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  dayAppointments['date'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...(dayAppointments['appointments'] as List).map((appointment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassContainer(
                    child: ListTile(
                      title: Text(appointment['patientName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appointment['type']),
                          Text(appointment['time']),
                          if (appointment['comment'] != null)
                            Text(
                              appointment['comment'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/doctor.jpg'),
              ),
              const SizedBox(height: 16),
              Text(
                'Доктор Петрова',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Терапевт',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация о враче',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.school),
                title: Text('Образование'),
                subtitle: Text(
                  'Первый МГМУ им. И.М. Сеченова\n'
                  'Специальность: Лечебное дело\n'
                  'Год выпуска: 2010',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.workspace_premium),
                title: Text('Квалификация'),
                subtitle: Text(
                  'Врач-терапевт высшей категории\n'
                  'Кандидат медицинских наук',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.work),
                title: Text('Опыт работы'),
                subtitle: Text('14 лет'),
              ),
              const ListTile(
                leading: Icon(Icons.star),
                title: Text('Специализация'),
                subtitle: Text(
                  '• Общая терапия\n'
                  '• Кардиология\n'
                  '• Профилактическая медицина',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.verified),
                title: Text('Сертификаты'),
                subtitle: Text(
                  '• Терапия (действителен до 2025)\n'
                  '• Кардиология (действителен до 2026)\n'
                  '• УЗИ-диагностика (действителен до 2024)',
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
                'Дополнительно',
                style: Theme.of(context).textTheme.titleLarge,
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
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
                        'HappyHUB - Ваш персональный медицинский помощник\n\n'
                        'Версия: 1.0.0\n\n'
                        'Разработано командой HappyHub\n'
                        '© 2024 Все права защищены\n\n'
                        'Приложение предназначено для:\n'
                        '• Управления приемами пациентов\n'
                        '• Ведения медицинской документации\n'
                        '• Общения с пациентами\n'
                        '• Анализа медицинских данных с помощью AI'
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
                leading: const Icon(Icons.logout),
                title: const Text('Выйти'),
                onTap: () {
                  context.read<AuthProvider>().logout();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}