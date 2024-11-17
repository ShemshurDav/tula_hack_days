class UserProfile {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String gender;
  final double height;
  final double weight;
  final List<String> chronicDiseases;
  final List<String> allergies;
  final String bloodType;
  final Map<String, dynamic> additionalInfo;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.height,
    required this.weight,
    required this.chronicDiseases,
    required this.allergies,
    required this.bloodType,
    this.additionalInfo = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserProfile(
        id: '',
        fullName: '',
        birthDate: DateTime.now(),
        gender: '',
        height: 0,
        weight: 0,
        chronicDiseases: [],
        allergies: [],
        bloodType: '',
      );
    }
    
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      height: json['height'] as double,
      weight: json['weight'] as double,
      chronicDiseases: List<String>.from(json['chronicDiseases']),
      allergies: List<String>.from(json['allergies']),
      bloodType: json['bloodType'] as String,
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'birthDate': birthDate.toIso8601String(),
    'gender': gender,
    'height': height,
    'weight': weight,
    'chronicDiseases': chronicDiseases,
    'allergies': allergies,
    'bloodType': bloodType,
    'additionalInfo': additionalInfo,
  };
} 