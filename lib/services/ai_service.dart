import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/medication.dart';

class AIService {
  static const String _baseUrl = 'https://api.zukijourney.com/v1';
  static const String _apiKey = 'zu-bdbd5315e8b2731e3a23a6d48a43a094';
  
  bool _isServiceAvailable = true;

  Future<String> getAIResponse(String prompt) async {
    try {
      const systemPrompt = '''
      Вы - медицинский AI-ассистент. Ваша задача - помогать пациентам с вопросами о здоровье и медицине.
      
      Правила общения:
      1. Обращайтесь к пациенту на "Вы"
      2. Отвечайте только на вопросы, связанные с медициной и здоровьем
      3. При вопросах не по теме медицины, вежливо объясните, что можете консультировать только по медицинским вопросам
      4. Не ставьте диагнозы, а рекомендуйте обратиться к врачу при серьезных симптомах
      5. Давайте только научно обоснованные рекомендации
      ''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.2-90b-instruct',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _isServiceAvailable = false;
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      _isServiceAvailable = false;
      throw Exception('Error connecting to AI service: $e');
    }
  }

  Future<String> getHealthAdvice(Map<String, dynamic> data) async {
    if (!_isServiceAvailable) {
      return _getOfflineHealthAdvice(data['current'] as Map<String, dynamic>);
    }

    try {
      final prompt = '''
      Проанализируйте показатели здоровья пациента:
      
      Текущие показатели:
      ${_formatMetricsForPrompt(data['current'] as Map<String, dynamic>)}
      
      История показателей за неделю:
      ${(data['history'] as List).map((m) => 
        '${m['timestamp']}: ${_formatMetricsForPrompt(m['values'] as Map<String, dynamic>)}'
      ).join('\n')}
      
      Профиль пациента:
      ${_formatProfileForPrompt(data['userProfile'] as Map<String, dynamic>?)}
      
      Пожалуйста, проанализируйте:
      1. Текущее состояние показателей
      2. Динамику изменений за неделю
      3. Учтите хронические заболевания
      4. Дайте рекомендации по образу жизни
      ''';

      final response = await getAIResponse(prompt);
      return _formatAIResponse(response);
    } catch (e) {
      _isServiceAvailable = false;
      return _getOfflineHealthAdvice(data['current'] as Map<String, dynamic>);
    }
  }

  String _formatMetricsForPrompt(Map<String, dynamic> metrics) {
    return metrics.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  String _formatProfileForPrompt(Map<String, dynamic>? profile) {
    if (profile == null) return 'Профиль недоступен';
    
    return '''
    Возраст: ${DateTime.now().year - DateTime.parse(profile['birthDate']).year} лет
    Пол: ${profile['gender']}
    Рост: ${profile['height']} см
    Вес: ${profile['weight']} кг
    Хронические заболевания: ${(profile['chronicDiseases'] as List).join(', ')}
    Аллергии: ${(profile['allergies'] as List).join(', ')}
    Группа крови: ${profile['bloodType']}
    ''';
  }

  String _formatAIResponse(String response) {
    // Очищаем от лишних пробелов и переносов строк
    response = response.trim().replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Форматируем заголовки
    final lines = response.split('\n');
    final formattedLines = lines.map((line) {
      // Если строка начинается с # или является заголовком в скобках
      if (line.startsWith('#') || (line.startsWith('[') && line.endsWith(']'))) {
        return '**$line**';
      }
      return line;
    }).toList();
    
    return formattedLines.join('\n');
  }

  String _getOfflineHealthAdvice(Map<String, dynamic> healthData) {
    final List<String> advice = [];
    
    healthData.forEach((key, value) {
      final numValue = double.tryParse(value.toString());
      if (numValue == null) return;

      switch (key) {
        case 'Давление':
          final pressureValues = value.toString().split('/');
          if (pressureValues.length == 2) {
            final systolic = double.tryParse(pressureValues[0]);
            final diastolic = double.tryParse(pressureValues[1]);
            
            if (systolic != null && diastolic != null) {
              if (systolic >= 180 || diastolic >= 110) {
                advice.add('ВНИМАНИЕ! Критически высокое давление ($value мм рт.ст.). Срочно обратитесь к врачу!');
              } else if (systolic >= 140 || diastolic >= 90) {
                advice.add('Повышенное давление ($value мм рт.ст.). Избегайте стрессов и физических нагрузок.');
              } else if (systolic < 90 || diastolic < 60) {
                advice.add('Пониженное давление ($value мм рт.ст.). Проконсультируйтесь с врачом.');
              }
            }
          }
          break;

        case 'Пульс':
          if (numValue >= 150) {
            advice.add('ВНИМАНИЕ! Критически высокий пульс ($value уд/мин). Срочно обратитесь к врачу!');
          } else if (numValue >= 100) {
            advice.add('Повышенный пульс ($value уд/мин). Рекомендуется отдых и наблюдение.');
          } else if (numValue < 50) {
            advice.add('Пониженный пульс ($value уд/мин). Проконсультируйтесь с врачом.');
          }
          break;

        case 'Температура':
          if (numValue >= 39.0) {
            advice.add('ВНИМАНИЕ! Высокая температура ($value°C). Срочно примите жаропонижающее!');
          } else if (numValue >= 37.5) {
            advice.add('Повышенная температура ($value°C). Рекомендуется постельный режим.');
          } else if (numValue < 36.0) {
            advice.add('Пониженная температура ($value°C). Согрейтесь и проконсультируйтесь с врачом.');
          }
          break;

        case 'Уровень сахара':
          if (numValue >= 11.0) {
            advice.add('ВНИМАНИЕ! Критически высокий уровень сахара ($value ммоль/л). Срочно обратитесь к врачу!');
          } else if (numValue >= 6.1) {
            advice.add('Повышенный уровень сахара ($value ммоль/л). Ограничьте потребление углеводов.');
          } else if (numValue <= 3.3) {
            advice.add('ВНИМАНИЕ! Низкий уровень сахара ($value ммоль/л). Срочно примите быстрые углеводы!');
          }
          break;

        case 'Сатурация':
          if (numValue <= 92) {
            advice.add('ВНИМАНИЕ! Критически низкая сатурация ($value%). Срочно обратитесь к врачу!');
          } else if (numValue <= 95) {
            advice.add('Пониженная сатурация ($value%). Рекомендуется консультация с врачом.');
          }
          break;

        case 'Холестерин':
          if (numValue >= 7.8) {
            advice.add('ВНИМАНИЕ! Критически высокий уровень холестерина ($value ммоль/л). Срочно обратитесь к врачу!');
          } else if (numValue >= 5.2) {
            advice.add('Повышенный уровень холестерина ($value ммоль/л). Рекомендуется пересмотреть диету и проконсультироваться с врачом.');
          }
          break;
      }
    });

    if (advice.isEmpty) {
      return 'Все показатели в пределах нормы. Продолжайте следить за своим здоровьем!';
    }

    return 'Обратите внимание:\n\n${advice.join('\n\n')}';
  }

  Future<String> getMedicationAdvice(List<Medication> medications) async {
    if (!_isServiceAvailable) {
      return _getOfflineMedicationAdvice(medications);
    }

    try {
      final prompt = '''
      Проанализируйте следующий график приема лекарств:
      ${medications.map((m) => '${m.name} (${m.dosage}): ${m.schedule.map((t) => 
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
      ).join(', ')}').join('\n')}
      
      Пожалуйста, проверьте:
      1. Возможные взаимодействия между препаратами
      2. Оптимальность времени приема
      3. Общие рекомендации по приему
      ''';

      return await getAIResponse(prompt);
    } catch (e) {
      _isServiceAvailable = false;
      return _getOfflineMedicationAdvice(medications);
    }
  }

  String _getOfflineMedicationAdvice(List<Medication> medications) {
    return '''
    Общие рекомендации по приему лекарств:
    
    1. Соблюдайте указанное время приема
    2. Принимайте лекарства после еды, если не указано иное
    3. При появлении побочных эффектов обратитесь к врачу
    4. Не пропускайте приемы лекарств
    5. Храните лекарства в соответствии с инструкцией
    ''';
  }

  Future<String> analyzeImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      const systemPrompt = '''
      Вы - медицинский AI-ассистент. Проанализируйте изображение и дайте рекомендации, связанные со здоровьем.
      
      Правила:
      1. Обращайтесь к пациенту на "Вы"
      2. Комментируйте только медицинские аспекты изображения
      3. Не ставьте диагнозы
      4. При необходимости рекомендуйте обратиться к врачу
      ''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.2-90b-instruct',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Проанализируйте это изображение'},
          ],
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
} 