import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
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
                  'Общие настройки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Уведомления'),
                  subtitle: const Text('Включить push-уведомления'),
                  trailing: Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Switch(
                      value: settings.notificationsEnabled,
                      onChanged: settings.setNotificationsEnabled,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Темная тема'),
                  subtitle: const Text('Использовать темную тему'),
                  trailing: Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Switch(
                      value: settings.darkModeEnabled,
                      onChanged: settings.setDarkModeEnabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 