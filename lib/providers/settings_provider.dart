import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _defaultMetric = 'Пульс';
  
  // Маппинг для конвертации между русскими и английскими названиями
  final Map<String, String> _metricNamesMap = {
    'Пульс': 'heart_rate',
    'Давление': 'blood_pressure',
    'Температура': 'temperature',
    'Уровень сахара': 'blood_sugar',
    'Сатурация': 'saturation',
    'Холестерин': 'cholesterol',
  };

  final List<String> _availableMetrics = [
    'Пульс',
    'Давление',
    'Температура',
    'Уровень сахара',
    'Сатурация',
    'Холестерин',
  ];

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get defaultMetric => _defaultMetric;
  List<String> get availableMetrics => List.unmodifiable(_availableMetrics);
  
  // Геттер для получения английского названия текущей метрики
  String get defaultMetricEn => _metricNamesMap[_defaultMetric] ?? 'heart_rate';

  SettingsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
    _darkModeEnabled = _prefs.getBool('dark_mode_enabled') ?? false;
    // Загружаем метрику и проверяем, что она есть в списке доступных
    final savedMetric = _prefs.getString('default_metric') ?? 'Пульс';
    _defaultMetric = _availableMetrics.contains(savedMetric) ? savedMetric : 'Пульс';
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    try {
      await _prefs.setBool('notifications_enabled', value);
      _notificationsEnabled = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
      _notificationsEnabled = !value;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setDarkModeEnabled(bool value) async {
    try {
      await _prefs.setBool('dark_mode_enabled', value);
      _darkModeEnabled = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving dark mode setting: $e');
      _darkModeEnabled = !value;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setDefaultMetric(String metric) async {
    if (_availableMetrics.contains(metric)) {
      try {
        await _prefs.setString('default_metric', metric);
        _defaultMetric = metric;
        notifyListeners();
      } catch (e) {
        debugPrint('Error saving default metric: $e');
        rethrow;
      }
    }
  }
} 