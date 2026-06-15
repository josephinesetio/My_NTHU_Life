import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/auth_widgets.dart';
import 'home.dart';

class Login extends StatefulWidget {
  final VoidCallback onSwitchToSignup;
  final bool narrow;

  const Login({super.key, required this.onSwitchToSignup, this.narrow = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String id = '';
  String password = '';
  bool _passwordVisible = false;
  String? _error;
  bool _isLoading = false;

  static const Color _bgBlack = Color(0xFF0B090A);
  static const Color _cardDark = Color(0xFF16121E);
  static const Color _neonPurple = Color(0xFFC77DFF);
  static const Color _deepPurple = Color(0xFF7B2CBF);
  static const Color _borderPurple = Color(0xFF3C096C);
  static const Color _darkBorder = Color(0xFF240046);

  void _handleLogin() async {
    setState(() => _error = null);

    if (id.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('studentID', isEqualTo: id)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() => _error = 'Student ID not found.');
        return;
      }

      final email = userQuery.docs.first['email'];

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => Home(studentID: id),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderPurple, width: 1.2),
      ),
      child: TextField(
        obscureText: obscure,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: _neonPurple.withOpacity(0.7),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: _deepPurple, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: widget.narrow
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          "SYSTEM LOGIN",
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Authenticate your NTHU identity",
          style: GoogleFonts.outfit(fontSize: 13, color: _deepPurple),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1.5,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_neonPurple, _borderPurple]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 32),

        // Student ID field
        _buildInputField(
          label: "Student ID",
          icon: Icons.badge_outlined,
          onChanged: (v) => id = v,
        ),
        const SizedBox(height: 14),

        // Password field
        _buildInputField(
          label: "Password",
          icon: Icons.lock_outline_rounded,
          obscure: !_passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _deepPurple,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          onChanged: (v) => password = v,
        ),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showResetPasswordDialog(context),
            child: Text(
              "Forgot Password?",
              style: GoogleFonts.outfit(
                color: _neonPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Error banner
        if (_error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),

        // Login button
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFC77DFF)),
              )
            : GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A189A), Color(0xFF7B2CBF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _neonPurple.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: _deepPurple.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "INITIATE LOGIN",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

        // Switch to signup
        if (widget.narrow) ...[
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: widget.onSwitchToSignup,
              child: RichText(
                text: TextSpan(
                  text: "No account? ",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: GoogleFonts.outfit(
                        color: _neonPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showResetPasswordDialog(BuildContext parentContext) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (parentContext) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _borderPurple, width: 1.5),
        ),
        title: Text(
          "RESET PASSWORD",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: _neonPurple,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0B090A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderPurple, width: 1),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter your email",
              labelStyle: GoogleFonts.outfit(
                color: _neonPurple.withOpacity(0.7),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF7B2CBF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(parentContext),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: controller.text.trim(),
                );
                Navigator.pop(parentContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Reset link sent.",
                      style: GoogleFonts.outfit(),
                    ),
                    backgroundColor: _deepPurple,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                Navigator.pop(parentContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Error occurred"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _deepPurple,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _neonPurple.withOpacity(0.4)),
              ),
              child: Text(
                "SEND",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
