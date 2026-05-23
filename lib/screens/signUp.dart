import 'package:flutter/material.dart';
import 'package:my_nthu_life/data/studentData.dart';
import '../widgets/auth_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  final bool narrow;

  const SignUp({super.key, required this.onSwitchToLogin, this.narrow = false});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String id = '';
  String password = '';
  String confirm = '';
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  String? _error;

  void _handleSignup() async {
  setState(() => _error = null);

  if (id.isEmpty || password.isEmpty || confirm.isEmpty) {
    setState(() => _error = 'Please fill in all fields.');
    return;
  }

  if (password != confirm) {
    setState(() => _error = 'Passwords do not match.');
    return;
  }

  try {
    String email = "$id@mynthu.com";
    print(email);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("SIGNUP SUCCESS");
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created! Please log in.'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );

    widget.onSwitchToLogin();
  } on FirebaseAuthException catch (e) {
    print("ERROR CODE: ${e.code}");
    print("ERROR MESSAGE: ${e.message}");
    setState(() => _error = "${e.code}: ${e.message}");  
    }
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
                  Text(
                    "Create account",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Join NTHU Life and track your credits",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 28),

                  authInputField(
                    label: "Student ID",
                    icon: Icons.badge_outlined,
                    onChanged: (v) => id = v,
                  ),
                  const SizedBox(height: 14),

                  authInputField(
                    label: "Password",
                    icon: Icons.lock_outline_rounded,
                    obscure: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    onChanged: (v) => password = v,
                  ),

                  const SizedBox(height: 14),

                  authInputField(
                    label: "Confirm Password",
                    icon: Icons.lock_outline_rounded,
                    obscure: !_confirmVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                    ),
                    onChanged: (v) => confirm = v,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    authErrorBanner(_error!),
                  ],

                  const SizedBox(height: 24),

                  authPrimaryButton(
                    label: "Sign Up",
                    accent: const Color(0xFF3A52ED),
                    onTap: _handleSignup,
                  ),

                  if (widget.narrow) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: widget.onSwitchToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 13,
                            ),
                            children: const [
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const Spacer(), // keeps center feel
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
