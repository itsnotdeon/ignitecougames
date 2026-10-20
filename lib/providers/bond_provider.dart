import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bond_progress.dart';

class BondProvider extends ChangeNotifier {
  BondProgress _progress = BondProgress();

  BondProgress get progress => _progress;

  BondProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('bond_progress');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        _progress = BondProgress.fromJson(jsonString);
        notifyListeners();
      } catch (e) {
        // Fallback
      }
    }
  }

  Future<void> addXp(int amount) async {
    final newXp = _progress.xp + amount;
    _progress = _progress.copyWith(
      xp: newXp,
      gamesPlayed: _progress.gamesPlayed + 1,
    );
    notifyListeners();
    _saveToStorage();
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (!_progress.unlockedAchievements.contains(achievementId)) {
      final updatedList = List<String>.from(_progress.unlockedAchievements)..add(achievementId);
      _progress = _progress.copyWith(unlockedAchievements: updatedList);
      notifyListeners();
      _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bond_progress', _progress.toJson());
  }
}