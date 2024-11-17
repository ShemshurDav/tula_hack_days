import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_metrics.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com/v1';

  Future<Map<String, dynamic>> sendMetrics(HealthMetrics metrics) async {
    final response = await http.post(
      Uri.parse('$baseUrl/metrics'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metrics.toJson()),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to send metrics');
  }

  // Другие методы API...
} 