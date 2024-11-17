import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Помощь'),
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
                  'Часто задаваемые вопросы',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildFaqItem(
                  context,
                  'Как добавить нового пациента?',
                  'Перейдите в раздел "Пациенты" и нажмите кнопку "+" в правом верхнем углу.',
                ),
                _buildFaqItem(
                  context,
                  'Как начать чат с пациентом?',
                  'Откройте профиль пациента и нажмите на иконку сообщения.',
                ),
                _buildFaqItem(
                  context,
                  'Как изменить расписание приёмов?',
                  'В разделе "Расписание" выберите нужный день и нажмите на временной слот для редактирования.',
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
                  'Поддержка',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email поддержки'),
                  subtitle: Text('support@happyhub.ru'),
                ),
                const ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Телефон поддержки'),
                  subtitle: Text('+7 (800) 123-45-67'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }
} 