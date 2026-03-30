import 'package:flutter/material.dart';

import '../../app_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _loading = false;
  /// Member or healthcare professional only (admin uses /admin-login).
  String _role = AppSession.roleMember;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final saved = await AppSession.rememberedEmail();
    if (saved != null && saved.isNotEmpty && mounted) {
      _email.text = saved;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await AppSession.saveSignIn(
      email: _email.text.trim(),
      role: _role,
      rememberEmail: _remember,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    final dest = AppSession.homeRouteForRole(_role);
    Navigator.pushNamedAndRemoveUntil(context, dest, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border,
                      color: Color(0xFFFF3CAC), size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Creation",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sign in to continue your wellness journey",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email Address",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          hintText: "you@example.com",
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Enter your email";
                          }
                          final r =
                              RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                          if (!r.hasMatch(v.trim())) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Password",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          hintText: "••••••••",
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Enter your password";
                          }
                          if (v.length < 6) {
                            return "At least 6 characters (demo)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'I am signing in as',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _roleChip(
                              label: 'Wellness member',
                              value: AppSession.roleMember,
                              icon: Icons.favorite_outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _roleChip(
                              label: 'Healthcare professional',
                              value: AppSession.roleHealthcareProfessional,
                              icon: Icons.medical_services_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/admin-login'),
                          child: const Text(
                            'Administrator portal →',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                              ),
                              const Text("Remember me"),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password reset is not wired in this demo build.",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Color(0xFF9333EA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _loading ? null : _signIn,
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF9333EA),
                                ],
                              ),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or continue with"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _socialButton("Google", context),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _socialButton("Outlook", context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign up for free",
                                  style: TextStyle(
                                    color: Color(0xFFFF3CAC),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text.rich(
                TextSpan(
                  text: "By signing in, you agree to our ",
                  children: [
                    TextSpan(
                      text: "Terms of Service",
                      style: TextStyle(color: Color(0xFF9333EA)),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(color: Color(0xFF9333EA)),
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

  Widget _roleChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final on = _role == value;
    return Material(
      color: on
          ? const Color(0xFFEEF2FF)
          : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _role = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: on ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: on
                        ? const Color(0xFF3730A3)
                        : const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$text sign-in is not configured in this demo.")),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
