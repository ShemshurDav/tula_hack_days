import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = '';
  String _userId = '';
  String _userName = '';
  UserProfile? _userProfile;
  
  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userName => _userName;
  UserProfile? get userProfile => _userProfile;

  // Тестовые данные для демонстрации
  final Map<String, Map<String, String>> _users = {
    'doctor': {
      'password': 'doctor',
      'role': 'doctor',
      'name': 'Доктор Петрова',
      'id': 'doc_001',
      'photoUrl': 'assets/images/doctor.jpg',
    },
    'patient': {
      'password': 'patient',
      'role': 'patient',
      'name': 'Петров Петр Петрович',
      'id': 'pat_001',
      'photoUrl': 'assets/images/patient.jpg',
    }
  };

  String? _photoUrl;
  String? get photoUrl => _photoUrl;

  // Инициализируем тестовый профиль
  AuthProvider() {
    final testUser = _users['patient']!;
    _photoUrl = testUser['photoUrl'];
    _userProfile = UserProfile(
      id: 'test_user',
      fullName: testUser['name']!,
      birthDate: DateTime(1980, 5, 15),
      gender: 'Мужской',
      height: 175,
      weight: 75,
      chronicDiseases: ['Гипертония', 'Сахарный диабет 2 типа'],
      allergies: ['Пенициллин', 'Пыльца берёзы'],
      bloodType: 'A(II) Rh+',
      additionalInfo: {
        'Группа инвалидности': 'III группа',
        'Место проживания': 'г. Москва',
      },
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final user = _users[email];
      if (user == null || user['password'] != password) {
        throw 'Неверный логин или пароль';
      }

      _isAuthenticated = true;
      _userRole = user['role']!;
      _userId = user['id']!;
      _userName = user['name']!;
      _photoUrl = user['photoUrl'];
      
      // Обновляем профиль в соответствии с пользователем
      _userProfile = UserProfile(
        id: _userId,
        fullName: _userName,
        birthDate: DateTime(1980, 5, 15),
        gender: 'Мужской',
        height: 175,
        weight: 75,
        chronicDiseases: ['Гипертония', 'Сахарный диабет 2 типа'],
        allergies: ['Пенициллин', 'Пыльца берёзы'],
        bloodType: 'A(II) Rh+',
        additionalInfo: {
          'Группа инвалидности': 'III группа',
          'Место проживания': 'г. Москва',
        },
      );
      
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userRole = '';
    _userId = '';
    _userName = '';
    notifyListeners();
  }
} 