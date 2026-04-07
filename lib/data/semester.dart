class Semester {
  String semesterName;
  List<Map<String, dynamic>> courses;

  Semester({required this.semesterName, required this.courses});

  Map<String, dynamic> toJson() => { 
    'semesterName': semesterName, 
    'courses' : courses
  };

  // 'factory' to load data back from SharedPreferences
  factory Semester.fromJson(Map<String, dynamic> json){
    var rawCourses = json['courses'] as List? ?? [];
    
    List<Map<String, dynamic>> cleanedCourses = rawCourses.map((item){
      return Map<String, dynamic>.from(item);
    }).toList();

    return Semester(
      semesterName: json['semesterName'] ?? "Unknown",
      courses: cleanedCourses,
    );
  }
}
