import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_nthu_life/pet_files/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nthu_life/main.dart';
import 'package:my_nthu_life/pet_files/pet_data.dart';
import 'package:my_nthu_life/data/semester.dart';

class TaskListPage extends StatefulWidget{
  final String studentID;

  const TaskListPage({super.key, required this.studentID});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>{
  List<String> _courseNames = [];
  Map<String, List<dynamic>> _tasksByCourse = {};
  bool _isLoading = true;

  final List<String> _categories = ['Homework', 'Quiz', 'Midterm', 'Final', 'Project', 'Other'];

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Pull the live courses added from credit_page.dart / transcript.dart
    String? semestersEncoded = prefs.getString("Semesters_${widget.studentID}");
    List<String> extractedCourses = [];

    if (semestersEncoded != null) {
      final List<dynamic> decodedSemesters = jsonDecode(semestersEncoded);
      final List<Semester> semesters = decodedSemesters
          .map((item) => Semester.fromJson(item))
          .toList();

      for (var sem in semesters) {
        for (var course in sem.courses) {
          String name = course['name'] ?? 'Unknown Course';
          if (!extractedCourses.contains(name)) {
            extractedCourses.add(name);
          }
        }
      }
    }

    // 2. Pull saved quest logs for these courses
    String? tasksEncoded = prefs.getString("CourseTasks_${widget.studentID}");
    Map<String, List<dynamic>> loadedTasks = {};
    if (tasksEncoded != null) {
      Map<String, dynamic> rawMap = jsonDecode(tasksEncoded);
      rawMap.forEach((key, value) {
        loadedTasks[key] = List<dynamic>.from(value);
      });
    }

    setState(() {
      _courseNames = extractedCourses;
      _tasksByCourse = loadedTasks;
      _isLoading = false;
    });
  }

  // ===== SAVE USER QUEST TASKS =====
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(_tasksByCourse);
    await prefs.setString("CourseTasks_${widget.studentID}", encoded);
  }

  // ===== PET REWARD LOGIC =====
  Future<void> _claimQuestRewards(int exp, int coins) async {
    final prefs = await SharedPreferences.getInstance();
    final String? petJson = prefs.getString('user_streak_pet');

    if (petJson != null) {
      final pet = StreakPet.fromJson(Map<String, dynamic>.from(jsonDecode(petJson)));
      
      pet.completeTaskReward(expReward: exp, coinReward: coins);
      
      await prefs.setString('user_streak_pet', jsonEncode(pet.toJson()));
      
      // Update global listenable to instantly refresh the homepage dashboard container
      totalCreditsNotifier.value = totalCreditsNotifier.value;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Quest Cleared! Jamil received +$exp EXP & +$coins Coins!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getCategoryColor(String category){
    switch(category){
      case 'Homework': 
        return Colors.blue.shade600;
      case 'Quiz': 
        return Colors.orange.shade600;
      case 'Midterm': 
        return Colors.red.shade600;
      case 'Final': 
        return Colors.purple.shade600;
      case 'Project': 
        return Colors.teal.shade600;
      default: 
        return Colors.grey.shade600;
    }
  }

  // ===== DIALOG FOR ADDING A TASK TO A SPECIFIC COURSE =====
  void _showAddTaskDialog(String courseName) {
    String taskTitle = "";
    String selectedCategory = _categories.first;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState){
            return AlertDialog(
              title: Text("Add Task for $courseName", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Task Description (e.g., Midterm 2, Chapter 4)",
                      hintText: "E.g. Review Chapter 2, Finish lab report",
                    ),
                    onChanged: (value) => taskTitle = value,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Task Category",
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String category){
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue){
                        if (newValue != null){
                          setDialogState((){
                            selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (taskTitle.trim().isNotEmpty) {
                      setState(() {
                        if (_tasksByCourse[courseName] == null) {
                          _tasksByCourse[courseName] = [];
                        }
                        _tasksByCourse[courseName]!.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'title': taskTitle.trim(),
                          'isDone': false,
                          'exp': 20,  // Standard custom quest rewards
                          'coins': 5,
                        });
                      });
                      _saveTasks();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                ),
              ],
            );
        });
      },
    );
  }

  String capitalizeWords(String text) {
    return text
        .split(" ")
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : "")
        .join(" ");
  }

  // ===== UI MATRIX =====
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Study Quest Board", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData, // Manual sync option if they come directly from Transcript adjustments
          ),
        ],
      ),
      body: _courseNames.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "No courses found! Add courses in your Transcript/Credit page first to generate quest lines.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16, color: theme.onSurfaceVariant),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
              itemCount: _courseNames.length,
              itemBuilder: (context, index) {
                final courseName = _courseNames[index];
                final tasks = _tasksByCourse[courseName] ?? [];

                return Card(
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header showing Transcript Course
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark_added_rounded, color: theme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      capitalizeWords(courseName),
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_task, color: theme.primary),
                              onPressed: () => _showAddTaskDialog(courseName),
                              tooltip: "Add Quest Task",
                            ),
                          ],
                        ),
                        const Divider(height: 16),

                        // Sub-Task Checklist Loop
                        tasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "No active study quests. Tap the icon above to assign tasks!",
                                  style: TextStyle(fontSize: 13, color: theme.onSurfaceVariant, fontStyle: FontStyle.italic),
                                ),
                              )
                            : Column(
                                children: tasks.asMap().entries.map((entry) {
                                  var task = entry.value;
                                  String category = task['category'] ?? 'Other';

                                  return CheckboxListTile(
                                    activeColor: theme.primary,
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(category).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _getCategoryColor(category), width: 1)
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getCategoryColor(category)
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            task['title'],
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              decoration: task['isDone'] ? TextDecoration.lineThrough : null,
                                              color: task['isDone'] ? Colors.grey : theme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Text("🔥 ${task['exp']} EXP", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 12),
                                          Text("🪙 ${task['coins']} Coins", style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    value: task['isDone'],
                                    onChanged: task['isDone']
                                        ? null // Prevent farming completed quests
                                        : (bool? value) {
                                            setState(() {
                                              task['isDone'] = true;
                                            });
                                            _saveTasks();

                                            Provider.of<PetProvider>(context, listen: false).awardGrowthPoints(
                                              studentID: widget.studentID,
                                              exp: task['exp'],
                                              coins: task['coins'],
                                            );

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('✨ Quest Cleared! Your pet received +${task['exp']} EXP & +${task['coins']} Coins!'),
                                                backgroundColor: Colors.green.shade700,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}