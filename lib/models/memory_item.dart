import 'dart:convert';

class MemoryItem {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  final String category;
  final bool isFavorite;
  final String emoji;

  MemoryItem({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    this.category = 'Romance',
    this.isFavorite = false,
    this.emoji = '📸',
  });

  MemoryItem copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? date,
    String? category,
    bool? isFavorite,
    String? emoji,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date.toIso8601String(),
      'category': category,
      'isFavorite': isFavorite,
      'emoji': emoji,
    };
  }

  factory MemoryItem.fromMap(Map<String, dynamic> map) {
    return MemoryItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] != null 
          ? DateTime.tryParse(map['date']) ?? DateTime.now() 
          : DateTime.now(),
      category: map['category'] ?? 'Romance',
      isFavorite: map['isFavorite'] ?? false,
      emoji: map['emoji'] ?? '📸',
    );
  }

  String toJson() => json.encode(toMap());

  factory MemoryItem.fromJson(String source) =>
      MemoryItem.fromMap(json.decode(source));
}