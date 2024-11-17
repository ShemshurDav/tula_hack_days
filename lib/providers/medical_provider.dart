import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'dart:async'; // Добавляем импорт для Completer
import '../models/health_metrics.dart';
import '../models/medication.dart';
import '../services/ai_service.dart';
import 'connectivity_provider.dart';
import 'dart:io';

// Добавляем класс ChatMessage
class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;
  bool isRead;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.isRead = false,
  });
}

class MedicalProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final ConnectivityProvider _connectivityProvider;
  final List<HealthMetrics> _healthMetrics = [];
  final Map<String, List<Medication>> _medications = {};
  String? _lastAIAdvice;
  bool _isLoadingAdvice = false;
  final List<Appointment> _appointments = [];
  
  // Теперь эти поля будут работать корректно
  final List<ChatMessage> _aiChatHistory = [];
  final Map<String, Completer<String>> _pendingAIResponses = {};
  
  // Хранение истории чатов
  final Map<String, List<ChatMessage>> _chatHistory = {
    '1': [ // Иванов П.С.
      ChatMessage(
        sender: 'patient',
        text: 'Добрый день, доктор!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ],
    '2': [ // Петрова А.И.
      ChatMessage(
        sender: 'patient',
        text: 'Спасибо за консультацию',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ],
  };
  
  bool get isLoadingAdvice => _isLoadingAdvice;
  String? get lastAIAdvice => _lastAIAdvice;
  List<ChatMessage> get aiChatHistory => List.unmodifiable(_aiChatHistory);
  
  MedicalProvider(this._connectivityProvider) {
    _addTestData();
  }

  void _addTestData() {
    final now = DateTime.now();
    
    // Добавляем тестовые назначения для текущего пользователя
    _medications['test_user'] = [
      Medication(
        id: '1',
        name: 'Бисопролол',
        dosage: '5 мг',
        schedule: const [
          TimeOfDay(hour: 8, minute: 0),
        ],
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        instructions: 'Принимать утром до еды. При головокружении обратиться к врачу.',
      ),
      Medication(
        id: '2',
        name: 'Магний B6',
        dosage: '2 таблетки',
        schedule: const [
          TimeOfDay(hour: 9, minute: 0),
          TimeOfDay(hour: 21, minute: 0),
        ],
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        instructions: 'Принимать во время еды. Запивать большим количеством воды.',
      ),
    ];

    // Добавляем тестовые назначения для всех пользователей
    _medications['default'] = _medications['test_user'] ?? [];
    
    // Обновляем тестовые прошедшие приёмы с диагнозами и назначениями
    _appointments.add(
      Appointment(
        doctorName: 'Петров П.П.',
        specialty: 'Терапевт',
        dateTime: now.subtract(const Duration(days: 7)),
        comment: 'Плановый осмотр',
        diagnosis: 'ОРВИ, лёгкое течение',
        prescriptions: [
          'Парацетамол 500мг при температуре выше 38.5°C',
          'Ингавирин 90мг 1 раз в день 7 дней',
          'Полоскание горла раствором Хлоргексидина 3 раза в день'
        ],
        recommendations: [
          'Обильное питьё',
          'Постельный режим 3 дня',
          'Контроль температуры тела'
        ],
      ),
    );

    _appointments.add(
      Appointment(
        doctorName: 'Козлов К.К.',
        specialty: 'Кардиолог',
        dateTime: now.subtract(const Duration(days: 14)),
        comment: 'Консультация по результатам ЭКГ',
        diagnosis: 'Синусовая тахикардия',
        prescriptions: [
          'Биопролол 5мг 1 раз в день утром',
          'Магний B6 по 2 таблетки 2 раза в день'
        ],
        recommendations: [
          'Ограничить кофеин',
          'Нормализовать режим сна',
          'Контроль пульса 2 раза в день',
          'Повторная ЭКГ через месяц'
        ],
      ),
    );

    final testData = [
      {
        'timestamp': now.subtract(const Duration(days: 6)),
        'values': {
          'Пульс': '72',
          'Давление': '120/80',
          'Температура': '36.6',
          'Уровень сахара': '5.5',
          'Сатурация': '98',
          'Хоестерин': '4.2',
        },
      },
      {
        'timestamp': now.subtract(const Duration(days: 5)),
        'values': {
          'Пульс': '75',
          'Давление': '125/82',
          'Температура': '36.7',
          'Уровень сахара': '5.8',
          'Сатурация': '97',
          'Холестерин': '4.3',
        },
      },
      {
        'timestamp': now.subtract(const Duration(days: 4)),
        'values': {
          'Пульс': '68',
          'Давление': '118/75',
          'Темпертура': '36.5',
          'Уровень сахара': '5.2',
          'Сатурация': '99',
          'Холестерин': '4.1',
        },
      },
      {
        'timestamp': now.subtract(const Duration(days: 3)),
        'values': {
          'Пульс': '82',
          'Давление': '130/85',
          'Температура': '37.1',
          'Уровень саара': '6.0',
          'Сатурация': '96',
          'Холестерин': '4.4',
        },
      },
      {
        'timestamp': now.subtract(const Duration(days: 2)),
        'values': {
          'Пульс': '70',
          'Давление': '122/78',
          'Температура': '36.6',
          'Уровень сахра': '5.4',
          'Сатурация': '98',
          'Холестерин': '4.2',
        },
      },
      {
        'timestamp': now.subtract(const Duration(days: 1)),
        'values': {
          'Пульс': '73',
          'Давление': '124/80',
          'Температура': '36.8',
          'Уровень сахара': '5.6',
          'Сатурация': '97',
          'Холестерин': '4.3',
        },
      },
      {
        'timestamp': now,
        'values': {
          'Пульс': '71',
          'Давление': '121/79',
          'Температура': '36.7',
          'Уровень сахара': '5.5',
          'Сатурация': '98',
          'Холестерин': '4.2',
        },
      },
    ];

    // Обновляем даты в тестовых данных относительно текущего дня
    for (var data in testData) {
      _healthMetrics.add(HealthMetrics(
        id: data['timestamp'].toString(),
        patientId: 'test_user',
        timestamp: data['timestamp'] as DateTime,
        values: Map<String, dynamic>.from(data['values'] as Map),
      ));
    }

    // Добавляем тестовую рекомендацию AI
    _lastAIAdvice = 'Ваши показатели в норме. Продолжайте соблюдать назначенное лечение и режим дня. Рекомендуется умеренная физическая активность и контроль питания.';
  }
  
  List<HealthMetrics> get healthMetrics => List.unmodifiable(_healthMetrics);
  
  Future<void> addHealthMetrics(HealthMetrics metrics) async {
    // Находим индекс метрик за текущий день, если они есть
    final today = DateTime.now();
    final index = _healthMetrics.indexWhere((m) => 
      m.timestamp.year == today.year && 
      m.timestamp.month == today.month && 
      m.timestamp.day == today.day
    );

    // Если есть метрики за сегодня - заменяем их, иначе добавляем новые
    if (index != -1) {
      _healthMetrics[index] = metrics;
    } else {
      _healthMetrics.add(metrics);
    }
    notifyListeners();
    
    // Затем асинхронно получаем рекомендации
    _isLoadingAdvice = true;
    notifyListeners();
    
    try {
      if (_connectivityProvider.isOnline) {
        // Получаем все метрики за последнюю еделю
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final weekMetrics = _healthMetrics
          .where((m) => m.timestamp.isAfter(weekAgo))
          .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Создаем структуру данных с историей показателей
        final analysisData = {
          'current': metrics.values,
          'history': weekMetrics.map((m) => {
            'timestamp': m.timestamp.toIso8601String(),
            'values': m.values,
          }).toList(),
          'userProfile': metrics.userProfile?.toJson(),
        };

        _lastAIAdvice = await _aiService.getHealthAdvice(analysisData);
      } else {
        _lastAIAdvice = 'Нет подключения к интернету. Рекомендации недоступны.';
      }
      
      if (metrics.hasWarning) {
        await _notifyDoctor(metrics);
      }
    } catch (e) {
      debugPrint('Ошибка при обработке показателей: $e');
      _lastAIAdvice = 'Не удалось получить рекомендации: $e';
    } finally {
      _isLoadingAdvice = false;
      notifyListeners();
    }
  }

  Future<void> setMedicationSchedule(String patientId, List<Medication> medications) async {
    _medications[patientId] = medications;
    notifyListeners();
  }

  List<Medication> getPatientMedications(String patientId) {
    return _medications[patientId] ?? [];
  }

  Future<void> _notifyDoctor(HealthMetrics metrics) async {
    final warnings = <String>[];
    
    metrics.values.forEach((key, value) {
      final numValue = double.tryParse(value.toString());
      if (numValue == null) return;

      switch (key) {
        case 'Давление':
          final parts = value.toString().split('/');
          if (parts.length == 2) {
            final systolic = double.tryParse(parts[0]);
            final diastolic = double.tryParse(parts[1]);
            if (systolic != null && diastolic != null) {
              if (systolic >= 140 || diastolic >= 90) {
                warnings.add('Повышенное давление: $value');
              } else if (systolic <= 90 || diastolic <= 60) {
                warnings.add('Пониженное давление: $value');
              }
            }
          }
          break;
        case 'Пульс':
          if (numValue >= 100) {
            warnings.add('Повышенный пульс: $value');
          } else if (numValue <= 50) {
            warnings.add('Пониженный пульс: $value');
          }
          break;
        // Добавьте другие показатели по аналогии
      }
    });

    if (warnings.isNotEmpty) {
      // Интеграция с Firebase Cloud Messaging или другой системой уведомлений
      final notification = {
        'title': 'Отклонение показателей',
        'body': warnings.join('\n'),
        'data': {
          'patientId': metrics.patientId,
          'timestamp': metrics.timestamp.toIso8601String(),
          'metrics': metrics.values,
        }
      };
      
      await _sendNotification(notification);
    }
  }

  Future<void> _sendNotification(Map<String, dynamic> notification) async {
    // TODO: Реализовать отправку уведомлений через Firebase или другой сервис
    debugPrint('Отправка уведомления: $notification');
  }

  List<Appointment> getAppointments() {
    return List.unmodifiable(_appointments);
  }

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    // Сортируем записи по дате
    _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    notifyListeners();
  }

  Future<void> cancelAppointment(DateTime dateTime) async {
    _appointments.removeWhere((appointment) => appointment.dateTime == dateTime);
    notifyListeners();
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return List.unmodifiable(
      _appointments.where((appointment) => appointment.dateTime.isAfter(now))
        .toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime))
    );
  }

  List<Appointment> getPastAppointments() {
    final now = DateTime.now();
    return List.unmodifiable(
      _appointments.where((appointment) => appointment.dateTime.isBefore(now))
        .toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime)) // Сортировка в обратном порядке
    );
  }

  // Добавляем геттер для доступа к AIService
  AIService get aiService => _aiService;

  // Метод для отправки сообщения AI и получения ответа
  Future<void> sendMessageToAI(String message) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = ChatMessage(
      sender: 'user',
      text: message,
      timestamp: DateTime.now(),
    );
    
    _aiChatHistory.add(userMessage);
    notifyListeners();

    // Создаем Completer ля этого сообщения
    final completer = Completer<String>();
    _pendingAIResponses[messageId] = completer;

    // Запускаем обработку в фоне
    _processAIResponse(message, messageId);

    // Возвращаем управление, не дожидаясь ответа
    return;
  }

  // Приватный метод для обработки ответа AI в фоне
  Future<void> _processAIResponse(String message, String messageId) async {
    try {
      final response = await _aiService.getAIResponse(message);
      
      final aiMessage = ChatMessage(
        sender: 'assistant',
        text: response,
        timestamp: DateTime.now(),
      );

      _aiChatHistory.add(aiMessage);
      _pendingAIResponses[messageId]?.complete(response);
      _pendingAIResponses.remove(messageId);
      
      notifyListeners();
    } catch (e) {
      final errorMessage = ChatMessage(
        sender: 'assistant',
        text: 'Извините, произошла ошибка. Попробуйте повторить вопрос позже.',
        timestamp: DateTime.now(),
      );

      _aiChatHistory.add(errorMessage);
      _pendingAIResponses[messageId]?.completeError(e);
      _pendingAIResponses.remove(messageId);
      
      notifyListeners();
    }
  }

  // Метод для проверки наличия необработанных ответов
  bool hasUnreadResponses() {
    return _pendingAIResponses.isNotEmpty;
  }

  // Метод для получения последнего сообщения
  ChatMessage? getLastAIMessage() {
    return _aiChatHistory.isEmpty ? null : _aiChatHistory.last;
  }

  Future<void> sendImageToAI(File image) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = ChatMessage(
      sender: 'user',
      text: 'Отправлено изображение',
      timestamp: DateTime.now(),
      imageUrl: image.path,
    );
    
    _aiChatHistory.add(userMessage);
    notifyListeners();

    final completer = Completer<String>();
    _pendingAIResponses[messageId] = completer;

    _processImageAIResponse(image, messageId);

    return;
  }

  Future<void> _processImageAIResponse(File image, String messageId) async {
    try {
      final response = await _aiService.analyzeImage(image);
      
      final aiMessage = ChatMessage(
        sender: 'assistant',
        text: response,
        timestamp: DateTime.now(),
      );

      _aiChatHistory.add(aiMessage);
      _pendingAIResponses[messageId]?.complete(response);
      _pendingAIResponses.remove(messageId);
      
      notifyListeners();
    } catch (e) {
      final errorMessage = ChatMessage(
        sender: 'assistant',
        text: 'Извините, не удалось обработать изображение. Попроуйте позже.',
        timestamp: DateTime.now(),
      );

      _aiChatHistory.add(errorMessage);
      _pendingAIResponses[messageId]?.completeError(e);
      _pendingAIResponses.remove(messageId);
      
      notifyListeners();
    }
  }

  // Получение истории чата с конкретным пациентом
  List<ChatMessage> getChatHistory(String patientId) {
    return _chatHistory[patientId] ?? [];
  }

  // Добавление нового сообщения в чат
  void addMessageToChat(String patientId, ChatMessage message) {
    if (!_chatHistory.containsKey(patientId)) {
      _chatHistory[patientId] = [];
    }
    _chatHistory[patientId]!.add(message);
    notifyListeners();
  }

  // Получение последнего сообщения для превью в списке чатов
  ChatMessage? getLastMessage(String patientId) {
    final messages = _chatHistory[patientId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  // Проверка наличия непрочитанных сообщений
  bool hasUnreadMessages(String patientId) {
    final messages = _chatHistory[patientId];
    if (messages == null || messages.isEmpty) return false;
    return messages.any((msg) => msg.sender == 'patient' && !msg.isRead);
  }

  // Метод для пометки всех сообщений в чате как прочитанных
  void markChatAsRead(String patientId) {
    if (_chatHistory.containsKey(patientId)) {
      bool hasUnreadMessages = false;
      for (var message in _chatHistory[patientId]!) {
        if (message.sender == 'patient' && !message.isRead) {
          message.isRead = true;
          hasUnreadMessages = true;
        }
      }
      // Уведомляем слушателей только если были непрочитанные сообщения
      if (hasUnreadMessages) {
        notifyListeners();
      }
    }
  }

  // Получение количества непрочитанных сообщений
  int getUnreadCount(String patientId) {
    final messages = _chatHistory[patientId];
    if (messages == null || messages.isEmpty) return 0;
    return messages.where((msg) => msg.sender == 'patient' && !msg.isRead).length;
  }

  void addMedicationForPatient(String patientId, Medication medication) {
    if (!_medications.containsKey(patientId)) {
      _medications[patientId] = [];
    }
    _medications[patientId]!.add(medication);
    notifyListeners();
  }
}

class Appointment {
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String? comment;
  final String? diagnosis;
  final List<String>? prescriptions;
  final List<String>? recommendations;

  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.comment,
    this.diagnosis,
    this.prescriptions,
    this.recommendations,
  });
} 