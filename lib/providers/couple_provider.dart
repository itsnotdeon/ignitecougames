import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/couple_profile.dart';

class CoupleProvider extends ChangeNotifier {
  CoupleProfile _profile = CoupleProfile();

  CoupleProfile get profile => _profile;

  CoupleProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('couple_profile');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        _profile = CoupleProfile.fromJson(jsonString);
        notifyListeners();
      } catch (e) {
        // Fallback to default
      }
    }
  }

  Future<void> updateProfile({
    String? partner1,
    String? partner2,
    DateTime? anniversaryDate,
    String? customName,
    String? emoji1,
    String? emoji2,
  }) async {
    _profile = _profile.copyWith(
      partner1: partner1,
      partner2: partner2,
      anniversaryDate: anniversaryDate,
      customName: customName,
      emoji1: emoji1,
      emoji2: emoji2,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('couple_profile', _profile.toJson());
  }
}