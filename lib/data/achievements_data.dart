class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpValue;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.xpValue = 50,
  });
}

class AchievementsData {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_spark',
      title: 'First Spark',
      description: 'Memulai sesi permainan pertama bersama.',
      icon: '✨',
      xpValue: 50,
    ),
    Achievement(
      id: 'memory_keeper',
      title: 'Memory Keeper',
      description: 'Menyimpan kenangan pertama di Scrapbook.',
      icon: '📖',
      xpValue: 50,
    ),
    Achievement(
      id: 'deep_diver',
      title: 'Deep Diver',
      description: 'Menjawab 5 pertanyaan Deep Talk tanpa ragu.',
      icon: '🌊',
      xpValue: 75,
    ),
    Achievement(
      id: 'after_dark_adventurer',
      title: 'After Dark Explorer',
      description: 'Menyelesaikan tantangan intim di mode After Dark.',
      icon: '🌙',
      xpValue: 100,
    ),
    Achievement(
      id: 'board_champions',
      title: 'Board Champions',
      description: 'Menyelesaikan 1 putaran Snake & Ladder Couple Edition.',
      icon: '🎲',
      xpValue: 80,
    ),
    Achievement(
      id: 'inseparable_streak',
      title: 'Unbreakable Bond',
      description: 'Mencapai streak bermain 7 hari berturut-turut.',
      icon: '🔥',
      xpValue: 150,
    ),
  ];
}