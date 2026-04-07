import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nthu_life/data/semester.dart';
import 'dart:convert';

class CreditPage extends StatefulWidget {
  // identitas halaman
  final String studentID;

  const CreditPage({super.key, required this.studentID});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  // ====== STATE VARIABLES ======
  
  final int graduationCredits = 128;
   List<Semester> semesters = [
    Semester(semesterName: "Semester 1", courses: [])
   ];
   int currentSemesterIndex = 0;

   @override
   void initState(){
    super.initState();
    loadCourses();
   }

  // ===== NEW STORAGE LOGIC =====
  Future<void> saveCourses() async{
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(semesters);
    await prefs.setString("Semesters_${widget.studentID}", encoded);
  }

  Future<void> loadCourses() async{
    final prefs = await SharedPreferences.getInstance();
    String? encoded = prefs.getString("Semesters_${widget.studentID}");

    if(encoded != null){
      final List<dynamic> decodedData = jsonDecode(encoded);
      setState(() {
        semesters = decodedData.map((item) => Semester.fromJson(item)).toList();
      });
    }
  }

  // ====== CALCULATIONS ======
  int get totalCredits {
    int sum = 0;

    for (var sem in semesters) {
      for(var course in sem.courses){
        sum += (course['credits'] as num).toInt();
      }
    }
    return sum;
  }

  int get remainingCredits {
    int remaining = graduationCredits - totalCredits;
    return remaining < 0 ? 0 : remaining;
  }

  // ====== UTIL ======
  String capitalizeWords(String text) {
    return text
        .split(" ")
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : "",
        )
        .join(" ");
  }

  // ====== CRUD ======
  void addCourse(String name, int credits) {
    setState(() {
      semesters[currentSemesterIndex].courses.add({'name': name, 'credits': credits});
    });

    saveCourses();
  }

  void deleteCourse(int index) {
    setState(() {
      semesters[currentSemesterIndex].courses.removeAt(index);
    });

    saveCourses();
  }

  // ====== UI HELPERS ======
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
              TextField(
                decoration: const InputDecoration(labelText: "Course Name"),
                onChanged: (value) => name = value,
              ),
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
                int? credits = int.tryParse(creditInput);

                if (name.isNotEmpty && credits != null) {
                  addCourse(name, credits);
                }

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // ====== BUILD UI ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          onPressed: showAddCourseDialog,
          child: const Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Credits: $totalCredits",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (totalCredits / graduationCredits).clamp(0.0, 1.0),
            ),

            const SizedBox(height: 8),

            Text(
              "$totalCredits / $graduationCredits credits",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Remaining: $remainingCredits credits",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: (){
                  setState(() {
                      semesters.add(Semester(semesterName: "Semester ${semesters.length + 1}", courses: []));

                    currentSemesterIndex = semesters.length - 1;
                  });
                  saveCourses();
                },
                icon: const Icon(Icons.add),
                label: const Text("New Semester"),
              )
          ],
          ),
        const SizedBox(height: 10),

        Expanded(
          child: semesters.isEmpty ? const Center(child: Text("No semesters added yet")) : ListView.builder(
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final semester = semesters[index];

              List<Widget> courseWidgets = semester.courses.asMap().entries.map((entry){
                return Card(
                  child: ListTile(
                    title: Text(capitalizeWords(entry.value['name'])),
                    subtitle: Text("${entry.value['credits']} credits"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: (){
                        setState(() => semesters[index].courses.removeAt(entry.key));
                        saveCourses();
                      },
                    ),
                  ),
                );
              }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              semester.semesterName,
                              style: const TextStyle(
                              fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white // Or your theme color
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState((){
                                  currentSemesterIndex = index;
                                });
                                showAddCourseDialog();
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Add course"),
                            ),
                          ],
                        ),
                      ),
                      ...courseWidgets,
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
