import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIStudyMaterialWidget extends StatelessWidget {
  const AIStudyMaterialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DARK MODE COLOR THEME CONFIGURATION ---
    const primaryPurple = Color(0xFF9F7AEA); // Brighter purple vibrant enough for dark mode
    const bgDark = Color(0xFF121212); // Deep dark background for the scaffold
    const cardBg = Color(0xFF1F1B24); // Surface card color (dark violet tint)
    const textLight = Colors.white; // Main text color
    const textMuted = Color(0xFFA0AEC0); // Subdued grayish-blue text for secondary info
    const borderPurple = Color(0xFF3C344C); // Dark purple outline borders

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER SECTION ---
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: primaryPurple,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "AI study helper",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textLight,
                    ),
                  ),
                  // Using Spacer instead of MainAxisAlignment.between to avoid hidden character compile bugs
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history, color: textLight, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Your personal AI companion to help you study smarter.",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // --- 2. AI COMPANION PROMPT CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderPurple),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: primaryPurple,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hi there! 👋",
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ask me anything about your topic,\nand I'll help you learn better.",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: GoogleFonts.outfit(color: textLight),
                      decoration: InputDecoration(
                        hintText: "e.g. Explain photosynthesis in simple terms",
                        hintStyle: GoogleFonts.outfit(
                          color: textMuted.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        fillColor: const Color(0xFF2D2636), // Slightly lighter container backdrop
                        filled: true,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderPurple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActionButton(Icons.menu_book_outlined, "Explain a topic", primaryPurple, borderPurple),
                          _buildActionButton(Icons.description_outlined, "Summarize notes", primaryPurple, borderPurple),
                          _buildActionButton(Icons.play_circle_outline_rounded, "Recommend videos", primaryPurple, borderPurple),
                          _buildActionButton(Icons.more_horiz, "More", primaryPurple, borderPurple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. YOUTUBE STUDY VIDEOS SECTION ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderPurple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Color(0xFFFF0000), // YouTube Red Color
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Recommended videos for you",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                      ],
                    ),
                    const SizedBox(height: 4),
                  
                    const SizedBox(height: 16),
                    _buildVideoPlaceholderItem(textMuted, borderPurple),
                    Divider(height: 24, color: borderPurple.withOpacity(0.5)),
                    _buildVideoPlaceholderItem(textMuted, borderPurple),
                    Divider(height: 24, color: borderPurple.withOpacity(0.5)),
                    _buildVideoPlaceholderItem(textMuted, borderPurple),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: borderPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View more on YouTube ",
                              style: GoogleFonts.outfit(
                                color: primaryPurple,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.launch_rounded, size: 14, color: primaryPurple),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 4. STUDY TIP BANNER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderPurple.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2636),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Study tip",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Use videos to understand concepts visually and reinforce your learning.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.personal_video_rounded,
                      size: 40,
                      color: borderPurple.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color primaryPurple, Color borderPurple) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          children: [
            Icon(icon, size: 14, color: primaryPurple),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        selected: false,
        onSelected: (_) {},
        backgroundColor: const Color(0xFF2D2636),
        side: BorderSide(color: borderPurple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildVideoPlaceholderItem(Color mutedColor, Color borderPurple) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2636),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: mutedColor, size: 28),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "10:00",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2636),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2636),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2636),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "  •  123K views  •  2 years ago",
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: mutedColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.more_vert_rounded, size: 18, color: mutedColor),
      ],
    );
  }
}