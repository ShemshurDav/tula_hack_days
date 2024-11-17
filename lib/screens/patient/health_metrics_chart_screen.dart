import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math' show min, max;
import '../../providers/medical_provider.dart';


class HealthMetricsChartScreen extends StatelessWidget {
  final String metricName;
  
  const HealthMetricsChartScreen({
    super.key,
    required this.metricName,
  });

  // Конвертируем английские названия в русские
  String _getMetricNameRu(String metricNameEn) {
    final Map<String, String> metricNamesRu = {
      'heart_rate': 'Пульс',
      'blood_pressure': 'Давление',
      'temperature': 'Температура',
      'blood_sugar': 'Уровень сахара',
      'saturation': 'Сатурация',
      'cholesterol': 'Холестерин',
    };
    return metricNamesRu[metricNameEn] ?? metricNameEn;
  }

  double _parseMetricValue(String metricName, dynamic value) {
    if (metricName == 'Давление') {
      final parts = value.toString().split('/');
      return double.parse(parts[0]);
    }
    return double.parse(value.toString());
  }

  String _getMetricDescription(String metricName) {
    switch (metricName) {
      case 'Пульс':
        return 'Частота сердечных сокращений в минуту';
      case 'Давление':
        return 'На графике отображается систолическое (верхнее) давление';
      case 'Температура':
        return 'Температура тела в градусах Цельсия';
      case 'Уровень сахара':
        return 'Концентрация глюкозы в крови натощак';
      case 'Сатурация':
        return 'Уровень насыщения крови кислородом';
      case 'Холестерин':
        return 'Уровень общего холестерина в крови';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalProvider>(
      builder: (context, medical, _) {
        final metricNameRu = _getMetricNameRu(metricName);
        final metrics = [...medical.healthMetrics]
            .where((m) => m.values.containsKey(metricNameRu))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (metrics.isEmpty) {
          return const Center(
            child: Text('Нет данных для отображения'),
          );
        }

        final values = metrics
            .map((m) => _parseMetricValue(metricNameRu, m.values[metricNameRu]))
            .toList();
        final minY = (values.reduce(min) - 5).floorToDouble();
        final maxY = (values.reduce(max) + 5).ceilToDouble();
        final interval = ((maxY - minY) / 5).ceilToDouble();

        // Получаем единицы измерения для метрики
        String unit = '';
        switch (metricNameRu) {
          case 'Пульс':
            unit = 'уд/мин';
          case 'Давление':
            unit = 'мм рт.ст.';
          case 'Температура':
            unit = '°C';
          case 'Уровень сахара':
            unit = 'ммоль/л';
          case 'Сатурация':
            unit = '%';
          case 'Холестерин':
            unit = 'ммоль/л';
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_getMetricDescription(metricNameRu).isNotEmpty) ...[
                Text(
                  _getMetricDescription(metricNameRu),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(unit, style: const TextStyle(fontSize: 12)),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= metrics.length) return const Text('');
                            return Text(
                              '${metrics[value.toInt()].timestamp.day}/${metrics[value.toInt()].timestamp.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: (metrics.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(metrics.length, (index) {
                          return FlSpot(
                            index.toDouble(),
                            _parseMetricValue(metricNameRu, metrics[index].values[metricNameRu]),
                          );
                        }),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 