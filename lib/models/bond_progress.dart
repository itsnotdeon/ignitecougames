import 'dart:convert';

class BondProgress {
  final int xp;
  final int gamesPlayed;
  final int streakDays;
  final List<String> unlockedAchievements;

  BondProgress({
    this.xp = 120,
    this.gamesPlayed = 3,
    this.streakDays = 5,
    List<String>? unlockedAchievements,
  }) : unlockedAchievements = unlockedAchievements ?? ['first_spark', 'memory_keeper'];

  int get level {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    return (xp / 300).floor() + 1;
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Kindling Sparks';
      case 2:
        return 'Sweet Flame';
      case 3:
        return 'Deep Resonance';
      case 4:
        return 'Passionate Blaze';
      case 5:
        return 'Harmonious Souls';
      default:
        return 'Eternal Ignite';
    }
  }

  int get nextLevelXp {
    switch (level) {
      case 1: return 100;
      case 2: return 300;
      case 3: return 600;
      case 4: return 1000;
      case 5: return 1500;
      default: return level * 300;
    }
  }

  int get currentLevelBaseXp {
    switch (level) {
      case 1: return 0;
      case 2: return 100;
      case 3: return 300;
      case 4: return 600;
      case 5: return 1000;
      default: return (level - 1) * 300;
    }
  }

  double get progressToNextLevel {
    final base = currentLevelBaseXp;
    final target = nextLevelXp;
    if (target <= base) return 1.0;
    return ((xp - base) / (target - base)).clamp(0.0, 1.0);
  }

  BondProgress copyWith({
    int? xp,
    int? gamesPlayed,
    int? streakDays,
    List<String>? unlockedAchievements,
  }) {
    return BondProgress(
      xp: xp ?? this.xp,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      streakDays: streakDays ?? this.streakDays,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'gamesPlayed': gamesPlayed,
      'streakDays': streakDays,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  factory BondProgress.fromMap(Map<String, dynamic> map) {
    return BondProgress(
      xp: map['xp'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      streakDays: map['streakDays'] ?? 1,
      unlockedAchievements: List<String>.from(map['unlockedAchievements'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BondProgress.fromJson(String source) =>
      BondProgress.fromMap(json.decode(source));
}