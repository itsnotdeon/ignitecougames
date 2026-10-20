import 'dart:convert';

class CoupleProfile {
  final String partner1;
  final String partner2;
  final DateTime anniversaryDate;
  final String? customName;
  final String emoji1;
  final String emoji2;

  CoupleProfile({
    this.partner1 = 'Alex',
    this.partner2 = 'Sam',
    DateTime? anniversaryDate,
    this.customName,
    this.emoji1 = '👑',
    this.emoji2 = '💖',
  }) : anniversaryDate = anniversaryDate ?? DateTime.now().subtract(const Duration(days: 180));

  int get daysTogether {
    final now = DateTime.now();
    return now.difference(anniversaryDate).inDays.abs();
  }

  String get displayName {
    if (customName != null && customName!.isNotEmpty) {
      return customName!;
    }
    return '$partner1 & $partner2';
  }

  CoupleProfile copyWith({
    String? partner1,
    String? partner2,
    DateTime? anniversaryDate,
    String? customName,
    String? emoji1,
    String? emoji2,
  }) {
    return CoupleProfile(
      partner1: partner1 ?? this.partner1,
      partner2: partner2 ?? this.partner2,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      customName: customName ?? this.customName,
      emoji1: emoji1 ?? this.emoji1,
      emoji2: emoji2 ?? this.emoji2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partner1': partner1,
      'partner2': partner2,
      'anniversaryDate': anniversaryDate.toIso8601String(),
      'customName': customName,
      'emoji1': emoji1,
      'emoji2': emoji2,
    };
  }

  factory CoupleProfile.fromMap(Map<String, dynamic> map) {
    return CoupleProfile(
      partner1: map['partner1'] ?? 'Alex',
      partner2: map['partner2'] ?? 'Sam',
      anniversaryDate: map['anniversaryDate'] != null 
          ? DateTime.tryParse(map['anniversaryDate']) ?? DateTime.now() 
          : DateTime.now(),
      customName: map['customName'],
      emoji1: map['emoji1'] ?? '👑',
      emoji2: map['emoji2'] ?? '💖',
    );
  }

  String toJson() => json.encode(toMap());

  factory CoupleProfile.fromJson(String source) =>
      CoupleProfile.fromMap(json.decode(source));
}