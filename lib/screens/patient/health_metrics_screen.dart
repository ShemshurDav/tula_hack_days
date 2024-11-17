import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../models/health_metrics.dart';
import '../../widgets/glass_container.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'Пульс': TextEditingController(),
    'Давление (верхнее)': TextEditingController(),
    'Давление (нижнее)': TextEditingController(),
    'Температура': TextEditingController(),
    'Уровень сахара': TextEditingController(),
    'Сатурация': TextEditingController(),
    'Холестерин': TextEditingController(),
  };

  final Map<String, String> _units = {
    'Пульс': 'уд/мин',
    'Давление (верхнее)': 'мм рт.ст.',
    'Давление (нижнее)': 'мм рт.ст.',
    'Температура': '°C',
    'Уровень сахара': 'ммоль/л',
    'Сатурация': '%',
    'Холестерин': 'ммоль/л',
  };

  final Map<String, String> _validators = {
    'Пульс': r'^[0-9]{2,3}$',
    'Давление (верхнее)': r'^[0-9]{2,3}$',
    'Давление (нижнее)': r'^[0-9]{2,3}$',
    'Температура': r'^\d{2}(\.\d)?$',
    'Уровень сахара': r'^\d{1,2}(\.\d)?$',
    'Сатурация': r'^([0-9]{2}|100)$',
    'Холестерин': r'^\d{1,2}(\.\d)?$',
  };

  bool _isLoading = false;

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите значение';
    }

    final regex = RegExp(_validators[fieldName]!);
    if (!regex.hasMatch(value)) {
      return 'Неверный формат числа';
    }

    final numValue = double.tryParse(value);
    if (numValue == null) return 'Введите числовое значение';

    switch (fieldName) {
      case 'Пульс':
        if (numValue < 30 || numValue > 200) {
          return 'Пульс должен быть от 30 до 200';
        }
      case 'Давление (верхнее)':
        if (numValue < 70 || numValue > 200) {
          return 'Верхнее давление должно быть от 70 до 200';
        }
      case 'Давление (нижнее)':
        if (numValue < 40 || numValue > 130) {
          return 'Нижнее давление должно быть от 40 до 130';
        }
        // Прверяем соотношение с верхним давлением
        final systolic = double.tryParse(_controllers['Давление (верхнее)']!.text);
        if (systolic != null && numValue >= systolic) {
          return 'Нижнее давление должно быть меньше верхнего';
        }
      case 'Температура':
        if (numValue < 35.0 || numValue > 42.0) {
          return 'Температура должна быть от 35.0 до 42.0';
        }
      case 'Уровень сахара':
        if (numValue < 2.0 || numValue > 20.0) {
          return 'Уровень сахара должен быть от 2.0 до 20.0';
        }
      case 'Сатурация':
        if (numValue < 70 || numValue > 100) {
          return 'Сатурация должна быть от 70 до 100';
        }
      case 'Холестерин':
        if (numValue < 2.0 || numValue > 15.0) {
          return 'Уровень холестерина должен быть от 2.0 до 15.0';
        }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод показателей'),
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
                    'Текущие показатели',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._controllers.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key,
                        suffixText: _units[entry.key],
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => _validateField(value, entry.key),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Отправить показатели'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().userId;
      final userProfile = context.read<AuthProvider>().userProfile;
      
      final values = <String, dynamic>{
        'Пульс': _controllers['Пульс']!.text,
        'Температура': _controllers['Температура']!.text,
        'Уровень сахара': _controllers['Уровень сахара']!.text,
        'Сатурация': _controllers['Сатурация']!.text,
        'Холестерин': _controllers['Холестерин']!.text,
      };
      
      values['Давление'] = '${_controllers['Давление (верхнее)']!.text}/'
          '${_controllers['Давление (нижнее)']!.text}';

      final metrics = HealthMetrics(
        id: DateTime.now().toIso8601String(),
        patientId: userId,
        timestamp: DateTime.now(),
        values: values,
        userProfile: userProfile,
      );

      // Сначала показываем уведомление и закрываем экран
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Показатели успешно отправлены'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }

      // После закрытия экрана асинхронно обрабатываем метрики
      context.read<MedicalProvider>().addHealthMetrics(metrics);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
} 