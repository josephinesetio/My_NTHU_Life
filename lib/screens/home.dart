import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_nthu_life/main.dart'; // imports themeNotifier & totalCreditsNotifier
import 'package:my_nthu_life/screens/task_list_page.dart';
import 'package:my_nthu_life/widgets/pet_dashboard_widget.dart';
import 'package:my_nthu_life/screens/credit_page.dart';
import 'package:my_nthu_life/screens/gpa_predictor.dart';
import 'package:my_nthu_life/screens/profile.dart'; // imported profile target layout

class Home extends StatefulWidget {
  final String studentID;

  const Home({super.key, required this.studentID});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      _HomePage(studentID: widget.studentID),
      CreditPage(studentID: widget.studentID),
      GPAPredictor(studentID: widget.studentID),
      TaskListPage(studentID: widget.studentID),
      Center(
        child: Text(
          "Notes Page",
          style: GoogleFonts.outfit(fontSize: 18),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.15),
                      child: const Icon(Icons.person, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentID,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "NTHU Elite Student",
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // 1. Interactive Profile Screen Navigator Action
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text("Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context); // Dismiss sidebar drawer context
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(studentID: widget.studentID),
                    ),
                  );
                },
              ),

              // 2. Dark Mode Toggle
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentMode, _) {
                  final isDark = currentMode == ThemeMode.dark;
                  return ListTile(
                    leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    title: Text("Dark Mode", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: isDark,
                      activeColor: const Color(0xFF7C3AED),
                      onChanged: (val) {
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  );
                },
              ),

              // 3. Global Rank Option Button
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                title: Text("Global Rank", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#12",
                    style: GoogleFonts.outfit(color: Colors.amber.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const Spacer(),
              const Divider(height: 1),

              // 4. Log Out Option Button
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text("Log Out", style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.of(context).pushReplacementNamed('/'); 
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Credits'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'GPA'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final String studentID;

  const _HomePage({required this.studentID});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "STUDENT ID",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentID,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Track your progress, build your streak, and conquer your semester.",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Today",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: totalCreditsNotifier,
              builder: (context, credits, child) {
                return PetDashboardWidget(
                  currentCredits: credits,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}