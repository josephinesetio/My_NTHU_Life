// import 'package:flutter/material.dart';
/*
class Home extends StatelessWidget{
  final String studentID;
  const Home({super.key, required this.studentID});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to My NTHU Life')),
      body: Center(child: Text('Hello Student ID: $studentID')),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Home page after login
// This page handles credit tracking + course management
class Home extends StatefulWidget {
  final String studentID;

  const Home({super.key, required this.studentID});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // List to store all courses
  // Each course contains: name + credits
  List<Map<String, dynamic>> courses = [];

  // Total credits needed to graduate
  final int graduationCredits = 128;

  @override
  void initState() {
    super.initState();
    loadCourses(); // Load saved data when app starts
  }

  // Save courses to local storage (SharedPreferences)
  Future<void> saveCourses() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert list → JSON string
    String encoded = jsonEncode(courses);

    // Save using studentID as key (so each user has their own data)
    await prefs.setString("courses_${widget.studentID}", encoded);
  }

  // Load saved courses from local storage
  Future<void> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    String? encoded = prefs.getString("courses_${widget.studentID}");

    if (encoded != null) {
      setState(() {
        courses = List<Map<String, dynamic>>.from(jsonDecode(encoded));
      });
    }
  }

  // Calculate total credits dynamically
  int get totalCredits {
    int sum = 0;

    for (var course in courses) {
      sum += course['credits'] as int;
    }

    return sum;
  }

  // Calculate remaining credits (prevent negative values)
  int get remainingCredits {
    int remaining = graduationCredits - totalCredits;
    return remaining < 0 ? 0 : remaining;
  }

  // Capitalize each word in course name
  String capitalizeWords(String text) {
    return text
        .split(" ")
        .map((word) =>
            word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : "")
        .join(" ");
  }

  // Add new course
  void addCourse(String name, int credits) {
    setState(() {
      courses.add({
        'name': name,
        'credits': credits,
      });
    });

    saveCourses(); // Save after adding
  }

  // Delete course
  void deleteCourse(int index) {
    setState(() {
      courses.removeAt(index);
    });

    saveCourses(); // Save after deleting
  }

  // Popup dialog to add course
  void showAddCourseDialog() {

    String name = "";
    String creditInput = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Input for course name
              TextField(
                decoration: const InputDecoration(labelText: "Course Name"),
                onChanged: (value) => name = value,
              ),

              // Input for credits
              TextField(
                decoration: const InputDecoration(labelText: "Credits"),
                keyboardType: TextInputType.number,
                onChanged: (value) => creditInput = value,
              ),

            ],
          ),

          actions: [
            TextButton(
              onPressed: () {

                // Safer parsing (avoid crash if invalid input)
                int? credits = int.tryParse(creditInput);

                if (name.isNotEmpty && credits != null) {
                  addCourse(name, credits);
                }

                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My NTHU Life"),
      ),

      // Floating button to add new course
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCourseDialog,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Greeting text
            Text(
              "Hello ${widget.studentID}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            // Total credits display
            Text(
              "Total Credits: $totalCredits",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Progress bar (clamped to avoid overflow)
            LinearProgressIndicator(
              value: (totalCredits / graduationCredits).clamp(0.0, 1.0),
            ),

            const SizedBox(height: 8),

            // Progress text
            Text(
              "$totalCredits / $graduationCredits credits",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 5),

            // Remaining credits
            Text(
              "Remaining: $remainingCredits credits",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            const Text(
              "Your Courses",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            // Course list / empty state
            Expanded(
              child: courses.isEmpty
                  ? const Center(
                      child: Text("No courses added yet"),
                    )
                  : ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {

                        var course = courses[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              title: Text(capitalizeWords(course['name'])),
                              subtitle: Text('${course['credits']} credits'),

                              // Delete button
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteCourse(index);
                                },
                              ),

                            ),
                          ),
                        );

                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}