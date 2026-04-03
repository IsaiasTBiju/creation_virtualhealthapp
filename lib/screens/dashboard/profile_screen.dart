import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_session.dart';
import '../../creation_palette.dart';

class ProfileScreen extends StatefulWidget {
  final CreationPalette palette;

  const ProfileScreen({super.key, required this.palette});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Alex Rivera";
  String _email = "alex@example.com";
  String _roleDisplay = "Wellness member";
  int _age = 28;
  String _gender = "Prefer not to say";
  double _heightCm = 172;
  double _weightKg = 70;

  @override
  void initState() {
    super.initState();
    _loadSessionProfile();
  }

  Future<void> _loadSessionProfile() async {
    final p = await SharedPreferences.getInstance();
    final n = p.getString(AppSession.keyDisplayName);
    final e = p.getString(AppSession.keyUserEmail);
    final r = p.getString(AppSession.keyUserRole);
    if (!mounted) return;
    setState(() {
      if (n != null && n.isNotEmpty) _name = n;
      if (e != null && e.isNotEmpty) _email = e;
      if (r == AppSession.roleAdmin) {
        _roleDisplay = "Administrator";
      } else if (r == AppSession.roleHealthcareProfessional) {
        _roleDisplay = "Healthcare professional";
      } else {
        _roleDisplay = "Wellness member";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _profileHero(),
            const SizedBox(height: 28),
            _detailsCard(),
            const SizedBox(height: 28),
            _goalsCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Your account and body metrics.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _primaryButton("Edit profile", _openEdit),
      ],
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4D79), Color(0xFFFF7A18)],
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _profileHero() {
    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: widget.palette.healthScoreGradient),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: widget.palette.brandGlowShadow,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _email,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _heroChip("BMI ${bmi.toStringAsFixed(1)}"),
                    const SizedBox(width: 10),
                    _heroChip("$_age yrs"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _infoRow(
            Icons.badge_outlined,
            "Account type",
            _roleDisplay,
          ),
          _infoRow(Icons.cake_outlined, "Age", "$_age"),
          _infoRow(Icons.wc_outlined, "Gender", _gender),
          _infoRow(Icons.height, "Height", "${_heightCm.round()} cm"),
          _infoRow(Icons.monitor_weight_outlined, "Weight", "${_weightKg.toStringAsFixed(1)} kg"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.palette.settingsSectionIconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: widget.palette.settingsSectionIconForeground, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Health goals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Stay consistent with movement, sleep, and mindfulness.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          _goalLine("Weekly active minutes", 0.72, "108 / 150"),
          const SizedBox(height: 16),
          _goalLine("Sleep consistency", 0.55, "4 / 7 nights"),
          const SizedBox(height: 16),
          _goalLine("Mindfulness sessions", 0.80, "4 / 5 goal"),
        ],
      ),
    );
  }

  Widget _goalLine(String label, double value, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              caption,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
                widget.palette.accentViolet),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 20,
          offset: const Offset(0, 10),
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }

  void _openEdit() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final ageCtrl = TextEditingController(text: _age.toString());
    String gender = _gender;
    final heightCtrl = TextEditingController(text: _heightCm.round().toString());
    final weightCtrl = TextEditingController(text: _weightKg.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _dialogField("Full name", nameCtrl),
                    const SizedBox(height: 12),
                    _dialogField("Email", emailCtrl, email: true),
                    const SizedBox(height: 12),
                    _dialogField("Age", ageCtrl, number: true),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: _inputDeco("Gender"),
                      items: const [
                        "Female",
                        "Male",
                        "Non-binary",
                        "Prefer not to say",
                      ]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setLocal(() => gender = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _dialogField("Height (cm)", heightCtrl, number: true),
                    const SizedBox(height: 12),
                    _dialogField("Weight (kg)", weightCtrl),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final nav = Navigator.of(context);
                          final newName = nameCtrl.text.trim().isEmpty
                              ? _name
                              : nameCtrl.text.trim();
                          final newEmail = emailCtrl.text.trim().isEmpty
                              ? _email
                              : emailCtrl.text.trim();
                          setState(() {
                            _name = newName;
                            _email = newEmail;
                            _age = int.tryParse(ageCtrl.text) ?? _age;
                            _gender = gender;
                            _heightCm =
                                double.tryParse(heightCtrl.text) ?? _heightCm;
                            _weightKg =
                                double.tryParse(weightCtrl.text) ?? _weightKg;
                          });
                          final p = await SharedPreferences.getInstance();
                          await p.setString(
                              AppSession.keyDisplayName, _name);
                          await p.setString(AppSession.keyUserEmail, _email);
                          if (!mounted) return;
                          nav.pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4D79), Color(0xFFFF7A18)],
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController c, {
    bool email = false,
    bool number = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: number
          ? TextInputType.number
          : email
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: _inputDeco(label),
    );
  }
}
