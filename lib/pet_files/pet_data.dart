class StreakPet {
  final String id;
  String name;
  int currentLevel;
  int growthPoints;
  int currentStreak;
  String currentStage;

  StreakPet({
    required this.id,
    required this.name,
    this.currentLevel = 1,
    this.growthPoints = 0,
    this.currentStreak = 0,
    this.currentStage = 'egg',
  });


  // Converts a Map (read from local storage) back into a StreakPet object
  factory StreakPet.fromJson(Map<String, dynamic> json) {
    return StreakPet(
      id: json['id'] as String,
      name: json['name'] as String,
      currentLevel: json['currentLevel'] as int,
      growthPoints: json['growthPoints'] as int,
      currentStreak: json['currentStreak'] as int,
      currentStage: json['currentStage'] as String,
    );
  }

  // Converts the StreakPet object into a Map so it can be saved as a JSON string
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentLevel': currentLevel,
      'growthPoints': growthPoints,
      'currentStreak': currentStreak,
      'currentStage': currentStage,
    };
  }
}