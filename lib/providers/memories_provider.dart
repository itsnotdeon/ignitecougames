import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory_item.dart';

class MemoriesProvider extends ChangeNotifier {
  List<MemoryItem> _memories = [];

  List<MemoryItem> get memories => List.unmodifiable(_memories);
  List<MemoryItem> get favoriteMemories =>
      _memories.where((m) => m.isFavorite).toList();

  MemoriesProvider() {
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('couple_memories');
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        _memories = jsonList.map((e) => MemoryItem.fromJson(e)).toList();
        notifyListeners();
        return;
      } catch (e) {
        // Fallback to sample
      }
    }

    // Default romantic starter memories if empty
    _memories = [
      MemoryItem(
        id: 'mem_1',
        title: 'Kencan Pertama yang Berkesan',
        note: 'Secangkir kopi hangat dan obrolan berjam-jam yang membuat kita lupa waktu.',
        date: DateTime.now().subtract(const Duration(days: 120)),
        category: 'First Date',
        isFavorite: true,
        emoji: '☕',
      ),
      MemoryItem(
        id: 'mem_2',
        title: 'Melihat Senja Bersama',
        note: 'Duduk berdampingan menikmati warna langit sore sambil mendengarkan lagu favorit berdua.',
        date: DateTime.now().subtract(const Duration(days: 45)),
        category: 'Romance',
        isFavorite: false,
        emoji: '🌅',
      ),
    ];
    notifyListeners();
    _saveToStorage();
  }

  Future<void> addMemory(MemoryItem item) async {
    _memories.insert(0, item);
    notifyListeners();
    _saveToStorage();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final current = _memories[index];
      _memories[index] = current.copyWith(isFavorite: !current.isFavorite);
      notifyListeners();
      _saveToStorage();
    }
  }

  Future<void> deleteMemory(String id) async {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _memories.map((e) => e.toJson()).toList();
    await prefs.setStringList('couple_memories', jsonList);
  }
}