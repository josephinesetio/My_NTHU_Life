import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nthu_life/pet_files/pet_data.dart'; 

class PetDashboardWidget extends StatefulWidget {
  final int currentCredits;
  const PetDashboardWidget({super.key, required this.currentCredits});

  @override
  State<PetDashboardWidget> createState() => _PetDashboardWidgetState();
}

class _PetDashboardWidgetState extends State<PetDashboardWidget> {
  StreakPet? _currentPet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? petJson = prefs.getString('user_streak_pet');

    if (petJson != null) {
      final loadedPet = StreakPet.fromJson(Map<String, dynamic>.from(jsonDecode(petJson)));

      if (widget.currentCredits > loadedPet.coins) {
        loadedPet.coins = widget.currentCredits;
        await prefs.setString('user_streak_pet', jsonEncode(loadedPet.toJson()));
      }
      
      setState(() {
        _currentPet = loadedPet;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _initializeNewPet(String name) async {
    final newPet = StreakPet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      currentLevel: 1,
      growthPoints: 0,
      currentStreak: 7, 
      currentStage: 'egg',
      coins: 0
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_streak_pet', jsonEncode(newPet.toJson()));

    setState(() {
      _currentPet = newPet;
    });
  }

  Future<void> _simulateEarnEXP() async {
    if (_currentPet == null) return;

    setState(() {
      _currentPet!.completeTaskReward(
        expReward: 20,
        coinReward: 5,
      );
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_streak_pet', jsonEncode(_currentPet!.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_currentPet == null) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "You don't have a streak pet yet!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Hatch an egg and complete your daily targets in NTHYou to grow your companion.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _initializeNewPet("NTHU Buddy"),
                child: const Text("Hatch My First Egg"),
              ),
            ],
          ),
        ),
      );
    }

    final pet = _currentPet!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        _getPetAssetPath(pet.currentStage),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Name and Coin counter aligned together
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: Color(0xFFFFB74D),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${pet.coins}",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Lv. ${pet.currentLevel} • ${pet.currentStage.toUpperCase()}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Rank Row with Valorant Badge Icon Added Here!
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Valorant Rank Badge Image Asset
                          Image.asset(
                            _getRankBadgeAsset(pet.rank),
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback placeholder if image asset path isn't discovered yet
                              return const Icon(Icons.shield_rounded, size: 16, color: Colors.grey);
                            },
                          ),
                          const SizedBox(width: 5),
                          
                          // 2. Rank Text Name Label
                          Text(
                            pet.rank,
                            style: TextStyle(
                              color: _getRankColor(pet.rank),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),

                          // 3. Subtitle Text Segment
                          Expanded(
                            child: Text(
                              " • ${pet.title}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Streak Flame Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "🔥 ${pet.currentStreak} Day",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Growth Progress", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text("${pet.growthPoints} / 100 EXP", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pet.growthPoints / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _simulateEarnEXP,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text("Simulate Completing a Habit (+20 EXP)"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'Bronze':
        return const Color(0xFF8C5A2B);
      case 'Silver':
        return const Color(0xFF6E7C91);
      case 'Gold':
        return const Color(0xFFB38B2D);
      case 'Diamond':
        return const Color(0xFF3AA6A0);
      default:
        return Colors.black87;
    }
  }

  // NEW: Maps the competitive rank names to custom local Image Asset files
  String _getRankBadgeAsset(String rank) {
    switch (rank) {
      case 'Bronze':
        return 'assets/badge/bronze_badge.png';
      case 'Silver':
        return 'assets/badge/silver.png';
      case 'Gold':
        return 'assets/badge/gold_badge.png';
      case 'Diamond':
        return 'assets/badge/diamond_badge.png';
      default:
        return 'assets/badge/bronze_badge.png';
    }
  }

  String _getPetAssetPath(String stage) {
    switch (stage) {
      case 'egg': 
        return 'assets/pet/Egg.png';
      case 'baby': 
        return 'assets/pet/baby.png';
      case 'juvenile': 
        return 'assets/pet/juvenile.png';
      case 'adult': 
        return 'assets/pet/adult.png';
      default: 
        return 'assets/pet/adult.png';
    }
  }
}