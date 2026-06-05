import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  final bool narrow;

  const SignUp({super.key, required this.onSwitchToLogin, this.narrow = false});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String id = '';
  String email = '';
  String password = '';
  String confirm = '';
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  String? _error;
  bool _isLoading = false;

  static const Color _bgBlack = Color(0xFF0B090A);
  static const Color _cardDark = Color(0xFF16121E);
  static const Color _neonPurple = Color(0xFFC77DFF);
  static const Color _deepPurple = Color(0xFF7B2CBF);
  static const Color _borderPurple = Color(0xFF3C096C);

  void _handleSignup() async {
    setState(() => _error = null);

    if (id.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'studentID': id,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'courses': {},
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created! Please log in.',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: _deepPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      widget.onSwitchToLogin();
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: widget.narrow
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "CREATE ACCOUNT",
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Register your NTHU identity",
                    style: GoogleFonts.outfit(fontSize: 13, color: _deepPurple),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1.5,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_neonPurple, _borderPurple],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildInputField(
                    label: "Student ID",
                    icon: Icons.badge_outlined,
                    onChanged: (v) => id = v,
                  ),
                  const SizedBox(height: 14),

                  _buildInputField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => email = v,
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 14),

                  _buildInputField(
                    label: "Confirm Password",
                    icon: Icons.lock_outline_rounded,
                    obscure: !_confirmVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _deepPurple,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                    ),
                    onChanged: (v) => confirm = v,
                  ),

                  // Error banner
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                  ],

                  const SizedBox(height: 24),

                  // Sign up button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC77DFF),
                          ),
                        )
                      : GestureDetector(
                          onTap: _handleSignup,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A237E), Color(0xFF3A52ED)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF3A52ED).withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3A52ED,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "INITIALIZE ACCOUNT",
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

                  if (widget.narrow) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: widget.onSwitchToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: "Already registered? ",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "Log In",
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

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
