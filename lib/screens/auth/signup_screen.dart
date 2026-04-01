import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_session.dart';
import '../../api_service.dart'; // <-- Added the new API Service!

class SignupFlowScreen extends StatefulWidget {
  const SignupFlowScreen({super.key});

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  int step = -1;

  final _signupFormKey = GlobalKey<FormState>();
  final _ageFormKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  final age = TextEditingController();

  String gender = "";
  String pronouns = "";
  bool colorBlind = false;
  bool acceptedTerms = false;

  String hairStyle = "Short";
  String hairColor = "Black";
  String eyeColor = "Brown";
  String faceShape = "Oval";

  /// U-FR-1-1: User vs Healthcare Professional
  String accountRole = AppSession.roleMember;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      checkOnboardingStatus();
    });
  }

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppSession.keyLoggedIn) ?? false;
    final done =
        prefs.getBool(AppSession.keyOnboardingComplete) ?? false;

    if (!mounted) return;
    if (loggedIn) {
      final role = prefs.getString(AppSession.keyUserRole);
      final dest = AppSession.homeRouteForRole(role);
      Navigator.pushReplacementNamed(context, dest);
      return;
    }
    if (done) {
      Navigator.pushReplacementNamed(context, "/signin");
      return;
    }
    setState(() => step = 0);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    age.dispose();
    super.dispose();
  }

  // ---------- COMMON UI ----------

  TextStyle get _titleStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      );

  TextStyle get _sectionTitleStyle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      );

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 13,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget gradientButton(String text, VoidCallback onTap, {bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4D79),
                Color(0xFFFF7A18),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget card(Widget child) {
    return Center(
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.9, 360),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ---------- SPLASH ----------

  Widget splash() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          const SmoothParticles(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Origin Inc.",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF6C2CF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "presents",
                  style: TextStyle(
                    color: Color(0xFF6C2CF3),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFFB14EFF),
                        Color(0xFF6C2CF3),
                      ],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    "Creation",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- STEP 0: CREATE ACCOUNT ----------

  Widget account() {
    return card(
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.favorite_border,
                  color: Color(0xFFFF3CAC),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  "Creation",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text("Create Account", style: _titleStyle),
            const SizedBox(height: 6),
            const Text(
              "Start your wellness journey today",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _signupFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: _fieldDecoration("Full Name", hint: "Enter your name"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter your full name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration("Email Address", hint: "you@example.com"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter your email";
                      }
                      final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                      if (!emailRegex.hasMatch(v.trim())) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: pass,
                    obscureText: true,
                    decoration: _fieldDecoration("Password", hint: "At least 6 characters"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter a password";
                      }
                      if (v.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirm,
                    obscureText: true,
                    decoration: _fieldDecoration("Confirm Password", hint: "Re-enter password"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (v != pass.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text("Account type", style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  _roleChoice(
                    "Wellness member",
                    AppSession.roleMember,
                  ),
                  _roleChoice(
                    "Healthcare professional",
                    AppSession.roleHealthcareProfessional,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acceptedTerms,
                        onChanged: (v) {
                          setState(() => acceptedTerms = v ?? false);
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: "By signing up, you agree to our "),
                              TextSpan(
                                text: "Terms",
                                style: TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // --- THE UPDATED BUTTON ---
                  gradientButton(
                    "Create Free Account",
                    () async {
                      if (_signupFormKey.currentState?.validate() ?? false) {
                        if (!acceptedTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please accept the Terms and Privacy Policy"),
                            ),
                          );
                          return;
                        }

                        // Show a loading snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Creating account in database...")),
                        );

                        // Call the API
                        bool success = await ApiService.registerUser(
                          email.text.trim(),
                          pass.text,
                          accountRole,
                        );

                        if (success) {
                          // If Python says OK, move to the avatar step!
                          setState(() => step = 1);
                        } else {
                          // If it fails (like email already exists), show an error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to create account. Email may already be in use."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  // --------------------------

                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/signin");
                },
                child: const Text(
                  "Already have an account? Sign in",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- STEP 1: GENDER + PRONOUNS ----------

  Widget genderStep() {
    return card(
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's get to know you", style: _titleStyle),
            const SizedBox(height: 24),
            Text("Gender Identity", style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _genderTile("Male", "male"),
            _genderTile("Female", "female"),
            _genderTile("Non-binary", "non-binary"),
            _genderTile("I don't want to say", "no-say"),
            const SizedBox(height: 24),
            Text("Preferred Pronouns", style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _pronounChipRow(),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: gradientButton(
                  "Continue",
                  () {
                    if (gender.isEmpty || pronouns.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select your gender identity and pronouns"),
                        ),
                      );
                      return;
                    }
                    setState(() => step = 2);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChoice(String label, String value) {
    final selected = accountRole == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => accountRole = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEEF2FF)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF9CA3AF),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderTile(String label, String value) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF111827),
        ),
      ),
      value: value,
      groupValue: gender,
      activeColor: const Color(0xFF4F46E5),
      onChanged: (v) => setState(() => gender = v ?? ""),
    );
  }

  Widget _pronounChipRow() {
    final options = ["He/Him", "She/Her", "They/Them", "Other"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((p) {
        final selected = pronouns == p;
        return ChoiceChip(
          label: Text(
            p,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF111827),
            ),
          ),
          selected: selected,
          selectedColor: const Color(0xFF4F46E5),
          backgroundColor: const Color(0xFFF3F4F6),
          onSelected: (_) => setState(() => pronouns = p),
        );
      }).toList(),
    );
  }

  // ---------- STEP 2: AVATAR ----------

  Widget avatarStep() {
    return card(
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create Your Avatar", style: _titleStyle),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 170,
                width: 170,
                child: _avatarPreview(),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionSection(
              "Hair Style",
              [
                "Short",
                "Long",
                "Curly",
                "Bald",
                "Ponytail",
                "Buzz Cut",
                "Wavy",
                "Afro",
                "Mohawk",
                "Bob",
              ],
              hairStyle,
              (v) => setState(() => hairStyle = v),
            ),
            _buildOptionSection(
              "Hair Color",
              [
                "Black",
                "Brown",
                "Blonde",
                "Red",
                "Auburn",
                "Gray",
                "White",
                "Blue",
                "Pink",
                "Purple",
              ],
              hairColor,
              (v) => setState(() => hairColor = v),
            ),
            _buildOptionSection(
              "Eye Color",
              [
                "Brown",
                "Blue",
                "Green",
                "Hazel",
                "Gray",
                "Amber",
              ],
              eyeColor,
              (v) => setState(() => eyeColor = v),
            ),
            _buildOptionSection(
              "Face Shape",
              [
                "Oval",
                "Round",
                "Square",
                "Heart",
                "Diamond",
              ],
              faceShape,
              (v) => setState(() => faceShape = v),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: gradientButton(
                  "Continue",
                  () => setState(() => step = 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSection(
    String title,
    List<String> options,
    String selected,
    void Function(String) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionTitleStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((o) {
              final isSelected = selected == o;
              return ChoiceChip(
                label: Text(
                  o,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF4F46E5),
                backgroundColor: const Color(0xFFF3F4F6),
                onSelected: (_) => onSelected(o),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _hairColorToColor() {
    switch (hairColor) {
      case "Black":
        return const Color(0xFF111827);
      case "Brown":
        return const Color(0xFF92400E);
      case "Blonde":
        return const Color(0xFFFACC15);
      case "Red":
        return const Color(0xFFDC2626);
      case "Auburn":
        return const Color(0xFFB45309);
      case "Gray":
        return const Color(0xFF9CA3AF);
      case "White":
        return const Color(0xFFF9FAFB);
      case "Blue":
        return const Color(0xFF2563EB);
      case "Pink":
        return const Color(0xFFEC4899);
      case "Purple":
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF111827);
    }
  }

  Color _eyeColorToColor() {
    switch (eyeColor) {
      case "Brown":
        return const Color(0xFF92400E);
      case "Blue":
        return const Color(0xFF2563EB);
      case "Green":
        return const Color(0xFF16A34A);
      case "Hazel":
        return const Color(0xFFA16207);
      case "Gray":
        return const Color(0xFF6B7280);
      case "Amber":
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF111827);
    }
  }

  Widget _avatarPreview() {
    return CustomPaint(
      painter: _FacePainter(faceShape),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HairPainter(hairStyle, _hairColorToColor()),
            ),
          ),
          Positioned(top: 72, left: 55, child: _eye(_eyeColorToColor())),
          Positioned(top: 72, right: 55, child: _eye(_eyeColorToColor())),
          Positioned(
            bottom: 40,
            left: 70,
            right: 70,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF9CA3AF),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9CA3AF), width: 1),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ---------- STEP 3: AGE ----------

  Widget ageStep() {
    return Center(
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.9, 360),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Form(
          key: _ageFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("How old are you?", style: _titleStyle.copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              TextFormField(
                controller: age,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration("Age", hint: "Enter your age"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Please enter your age";
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed <= 0 || parsed > 120) return "Please enter a valid age";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  child: gradientButton(
                    "Continue",
                    () {
                      if (_ageFormKey.currentState?.validate() ?? false) {
                        setState(() => step = 4);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- STEP 4: ACCESSIBILITY ----------

  Widget accessibility() {
    return Center(
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.9, 360),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Accessibility Settings", style: _titleStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              "Are you color blind?",
              style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: const Text("No", style: TextStyle(fontSize: 14)),
              value: false,
              groupValue: colorBlind,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (v) => setState(() => colorBlind = v ?? false),
            ),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: const Text("Yes", style: TextStyle(fontSize: 14)),
              value: true,
              groupValue: colorBlind,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (v) => setState(() => colorBlind = v ?? true),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                child: gradientButton(
                          "Continue to Dashboard",
                          () async {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Saving profile securely...")),
                            );

                            // 1. Silently log the user in to get their JWT token
                            String? token = await ApiService.loginUser(
                                email.text.trim(), 
                                pass.text
                            );

                            // 2. If login worked, save all the profile data we gathered!
                            if (token != null) {
                                await ApiService.createProfile(
                                    token: token,
                                    fullName: name.text.trim(),
                                    age: int.tryParse(age.text.trim()) ?? 0,
                                    gender: gender,
                                );
                            }

                            // 3. Save local session so the app remembers we are logged in
                            await AppSession.saveAfterOnboarding(
                              email: email.text.trim(),
                              displayName: name.text.trim(),
                              role: accountRole,
                            );
                            
                            if (!mounted) return;
                            final dest = AppSession.homeRouteForRole(accountRole);
                     Navigator.pushReplacementNamed(context, dest);
                   },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (step == -1) return splash();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: SmoothParticles()),
          IndexedStack(
            index: step,
            sizing: StackFit.expand,
            children: [
              account(),
              genderStep(),
              avatarStep(),
              ageStep(),
              accessibility(),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- FACE PAINTER ----------

class _FacePainter extends CustomPainter {
  final String shape;

  _FacePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 8),
      width: size.width * 0.62,
      height: size.height * 0.72,
    );

    switch (shape) {
      case "Round":
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(60)),
          paint,
        );
        break;

      case "Square":
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(16)),
          paint,
        );
        break;

      case "Heart":
        final path = Path();
        final top = Offset(size.width / 2, rect.top + 12);
        final left = Offset(rect.left + 12, rect.center.dy);
        final right = Offset(rect.right - 12, rect.center.dy);
        final bottom = Offset(size.width / 2, rect.bottom);

        path.moveTo(top.dx, top.dy);
        path.quadraticBezierTo(rect.left, rect.top, left.dx, left.dy);
        path.lineTo(bottom.dx, bottom.dy);
        path.lineTo(right.dx, right.dy);
        path.quadraticBezierTo(rect.right, rect.top, top.dx, top.dy);

        canvas.drawPath(path, paint);
        break;

      case "Diamond":
        final path = Path()
          ..moveTo(size.width / 2, rect.top)
          ..lineTo(rect.right, rect.center.dy)
          ..lineTo(size.width / 2, rect.bottom)
          ..lineTo(rect.left, rect.center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;

      default: // Oval
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(40)),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) => old.shape != shape;
}

// ---------- HYBRID HAIR PAINTER ----------

class _HairPainter extends CustomPainter {
  final String style;
  final Color color;

  _HairPainter(this.style, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (style == "Bald") return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (style) {
      case "Short":
        _drawShortHair(canvas, paint, w, h);
        break;
      case "Long":
        _drawLongHair(canvas, paint, w, h);
        break;
      case "Curly":
        _drawCurlyHair(canvas, paint, w, h);
        break;
      case "Wavy":
        _drawWavyHair(canvas, paint, w, h);
        break;
      case "Afro":
        _drawAfro(canvas, paint, w, h);
        break;
      case "Mohawk":
        _drawMohawk(canvas, paint, w, h);
        break;
      case "Buzz Cut":
        _drawBuzzCut(canvas, paint, w, h);
        break;
      case "Ponytail":
        _drawPonytail(canvas, paint, w, h);
        break;
      case "Bob":
        _drawBob(canvas, paint, w, h);
        break;
      default:
        _drawShortHair(canvas, paint, w, h);
    }
  }

  void _drawShortHair(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.2, h * 0.25)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.8, h * 0.25)
      ..quadraticBezierTo(w * 0.85, h * 0.35, w * 0.8, h * 0.45)
      ..quadraticBezierTo(w * 0.5, h * 0.30, w * 0.2, h * 0.45)
      ..quadraticBezierTo(w * 0.15, h * 0.35, w * 0.2, h * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawLongHair(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.2, h * 0.20)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.8, h * 0.20)
      ..quadraticBezierTo(w * 0.95, h * 0.55, w * 0.75, h * 0.90)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.25, h * 0.90)
      ..quadraticBezierTo(w * 0.05, h * 0.55, w * 0.2, h * 0.20)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCurlyHair(Canvas canvas, Paint paint, double w, double h) {
    for (double i = 0; i < 6; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * (0.15 + i * 0.14), h * 0.22),
          width: w * 0.22,
          height: h * 0.22,
        ),
        paint,
      );
    }
  }

  void _drawWavyHair(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.2, h * 0.25)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.8, h * 0.25)
      ..cubicTo(w * 0.9, h * 0.45, w * 0.6, h * 0.55, w * 0.8, h * 0.75)
      ..cubicTo(w * 0.6, h * 0.85, w * 0.4, h * 0.85, w * 0.2, h * 0.75)
      ..cubicTo(w * 0.4, h * 0.55, w * 0.1, h * 0.45, w * 0.2, h * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawAfro(Canvas canvas, Paint paint, double w, double h) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.25),
        width: w * 0.95,
        height: h * 0.55,
      ),
      paint,
    );
  }

  void _drawMohawk(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.45, h * 0.05)
      ..lineTo(w * 0.55, h * 0.05)
      ..lineTo(w * 0.60, h * 0.45)
      ..lineTo(w * 0.40, h * 0.45)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawBuzzCut(Canvas canvas, Paint paint, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.20),
          width: w * 0.75,
          height: h * 0.25,
        ),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  void _drawPonytail(Canvas canvas, Paint paint, double w, double h) {
    _drawLongHair(canvas, paint, w, h * 0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.85),
        width: w * 0.35,
        height: h * 0.35,
      ),
      paint,
    );
  }

  void _drawBob(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.2, h * 0.25)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.8, h * 0.25)
      ..quadraticBezierTo(w * 0.9, h * 0.55, w * 0.8, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.2, h * 0.75)
      ..quadraticBezierTo(w * 0.1, h * 0.55, w * 0.2, h * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HairPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.color != color;
  }
}

// ---------- BACKGROUND PARTICLES ----------

class SmoothParticles extends StatefulWidget {
  const SmoothParticles({super.key});

  @override
  State<SmoothParticles> createState() => _SmoothParticlesState();
}

class _SmoothParticlesState extends State<SmoothParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final int count = 50;
  final Random random = Random();

  late List<Offset> positions;
  late List<Offset> velocities;
  late List<Color> colors;

  @override
  void initState() {
    super.initState();

    positions = List.generate(
      count,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );

    velocities = List.generate(
      count,
      (_) => Offset(
        (random.nextDouble() - 0.5) * 0.001,
        (random.nextDouble() - 0.5) * 0.001,
      ),
    );

    final palette = [
      const Color(0xFFB14EFF),
      const Color(0xFFFF7A18),
      const Color(0xFF4BC0C8),
      const Color(0xFFFFC857),
      const Color(0xFF6C2CF3),
    ];

    colors = List.generate(
      count,
      (_) => palette[random.nextInt(palette.length)],
    );

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..addListener(() {
        setState(() {
          for (int i = 0; i < count; i++) {
            positions[i] += velocities[i];

            if (positions[i].dx < 0 || positions[i].dx > 1) {
              velocities[i] = Offset(-velocities[i].dx, velocities[i].dy);
            }
            if (positions[i].dy < 0 || positions[i].dy > 1) {
              velocities[i] = Offset(velocities[i].dx, -velocities[i].dy);
            }
          }
        });
      });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: ParticlePainter(positions, colors),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ---------- PARTICLE PAINTER ----------

class ParticlePainter extends CustomPainter {
  final List<Offset> positions;
  final List<Color> colors;

  ParticlePainter(this.positions, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFFB0B6C3).withOpacity(0.10)
      ..strokeWidth = 0.8;

    final scaled = positions
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    for (int i = 0; i < scaled.length; i++) {
      dotPaint.color = colors[i].withOpacity(0.25);
      canvas.drawCircle(scaled[i], 2.5, dotPaint);

      for (int j = i + 1; j < scaled.length; j++) {
        if ((scaled[i] - scaled[j]).distance < 120) {
          canvas.drawLine(scaled[i], scaled[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}