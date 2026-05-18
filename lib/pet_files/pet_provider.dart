import 'package:my_nthu_life/pet_files/pet_data.dart';
import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nthu_life/date_utils.dart'; // We will define this helper next

class PetProvider with ChangeNotifier {
  StreakPet? _currentPet;
  bool _isLoading = true;

  StreakPet? get currentPet => _currentPet;
  bool get isLoading => _isLoading;

  // 1. Load the pet data as soon as the app/feature starts
  Future<void> loadPet() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? petJson = prefs.getString('user_streak_pet');
    final String? lastLoginStr = prefs.getString('last_app_login_date');

    if (petJson == null) {
      // No pet exists yet! We'll leave it null so the UI knows to show a "Choose your Egg" screen
      _currentPet = null;
    } else {
      // A pet exists, decode it
      _currentPet = StreakPet.fromJson(Map<String, dynamic>.from(jsonDecode(petJson)));
      
      // 2. Check and update the streak based on the last login time
      if (lastLoginStr != null) {
        _checkAndUpdateStreak(DateTime.parse(lastLoginStr));
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. The core logic: checking the daily streak
  void _checkAndUpdateStreak(DateTime lastLoginDate) {
    if (_currentPet == null) return;

    final today = DateTime.now();
    final daysDifference = calculateDaysDifference(lastLoginDate, today);

    if (daysDifference == 1) {
      // Perfect! It's consecutive day. 
      // Note: We usually increment the streak when they actually complete a task, 
      // or right here if just opening the app is enough to maintain it.
    } else if (daysDifference > 1) {
      // Oh no, they missed a day! The streak breaks.
      _currentPet!.currentStreak = 0;
      _currentPet!.currentStage = 'sad_egg'; // or whatever status fits your mechanics
      savePet();
    }
  }

  // 3. Award experience/growth points when they complete an action in NTHYou
  void awardGrowthPoints(int points) {
    if (_currentPet == null) return;

    _currentPet!.growthPoints += points;

    // Handle leveling up or evolving
    if (_currentPet!.growthPoints >= 100) {
      _currentPet!.currentLevel += 1;
      _currentPet!.growthPoints = 0; // Reset or carry over leftover exp
      
      // Handle evolution stages
      if (_currentPet!.currentLevel == 5) _currentPet!.currentStage = 'baby';
      if (_currentPet!.currentLevel == 15) _currentPet!.currentStage = 'juvenile';
    }

    savePet();
  }

  // 4. Save the pet state to local storage
  Future<void> savePet() async {
    if (_currentPet == null) return;

    final prefs = await SharedPreferences.getInstance();
    final petJson = jsonEncode(_currentPet!.toJson());
    
    await prefs.setString('user_streak_pet', petJson);
    await prefs.setString('last_app_login_date', DateTime.now().toIso8601String());
    
    notifyListeners(); // Tell the UI to redraw with the new data
  }
}