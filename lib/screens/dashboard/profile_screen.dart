import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_session.dart';
import '../../api_service.dart';
import '../../creation_palette.dart';

import '../../widgets/avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  final CreationPalette palette;

  const ProfileScreen({super.key, required this.palette});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "";
  String _email = "";
  String _roleDisplay = "Wellness member";
  int _age = 0;
  String _gender = "Prefer not to say";
  double _heightCm = 0;
  double _weightKg = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // load from local session first
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

    // then fetch full profile from backend
    final token = await AppSession.getToken();
    if (token == null) return;
    final profile = await ApiService.getProfile(token);
    if (!mounted || profile == null) return;
    setState(() {
      if (profile['full_name'] != null) _name = profile['full_name'];
      if (profile['age'] != null) _age = (profile['age'] as num).toInt();
      if (profile['gender'] != null) _gender = profile['gender'];
      if (profile['height_cm'] != null) _heightCm = (profile['height_cm'] as num).toDouble();
      if (profile['weight_kg'] != null) _weightKg = (profile['weight_kg'] as num).toDouble();
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
            child: const ClipOval(child: UserAvatar(size: 84)),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Personal information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ],
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

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final ageCtrl = TextEditingController(text: '$_age');
    final genderCtrl = TextEditingController(text: _gender);
    final heightCtrl = TextEditingController(text: '${_heightCm.round()}');
    final weightCtrl = TextEditingController(text: _weightKg.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit profile'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 12),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: 'Gender')),
              const SizedBox(height: 12),
              TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = await AppSession.getToken();
              if (token == null) return;
              final body = <String, dynamic>{
                'full_name': nameCtrl.text.trim(),
                'age': int.tryParse(ageCtrl.text.trim()) ?? _age,
                'gender': genderCtrl.text.trim(),
                'height_cm': double.tryParse(heightCtrl.text.trim()) ?? _heightCm,
                'weight_kg': double.tryParse(weightCtrl.text.trim()) ?? _weightKg,
              };
              await ApiService.putData(token, 'profile', body);
              // update local session name
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(AppSession.keyDisplayName, nameCtrl.text.trim());
              _loadProfile();
            },
            child: const Text('Save'),
          ),
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
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadGamification(),
      builder: (ctx, snap) {
        final gam = snap.data;
        final points = gam?['total_points'] ?? 0;
        final streak = gam?['current_streak_days'] ?? 0;
        final level = gam?['level'] ?? 1;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text("Your current activity and wellness progress.", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              _goalLine("Level progress", (points % 100) / 100.0, "$points / ${(level) * 100} pts to next level"),
              const SizedBox(height: 16),
              _goalLine("Current streak", streak >= 7 ? 1.0 : streak / 7.0, "$streak / 7 days"),
              const SizedBox(height: 16),
              _goalLine("Points earned", points > 0 ? (points / 500.0).clamp(0.0, 1.0) : 0.0, "$points total points"),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadGamification() async {
    final token = await AppSession.getToken();
    if (token == null) return null;
    return await ApiService.getMap(token, 'gamification');
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
    final genderCtrl = TextEditingController(text: _gender);
    final heightCtrl = TextEditingController(text: _heightCm.round().toString());
    final weightCtrl = TextEditingController(text: _weightKg.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Edit profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    _dialogField("Full name", nameCtrl),
                    const SizedBox(height: 12),
                    _dialogField("Email", emailCtrl, email: true),
                    const SizedBox(height: 12),
                    _dialogField("Age", ageCtrl, number: true),
                    const SizedBox(height: 12),
                    _dialogField("Gender", genderCtrl),
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
                          setState(() {
                            _name = nameCtrl.text.trim().isEmpty ? _name : nameCtrl.text.trim();
                            _email = emailCtrl.text.trim().isEmpty ? _email : emailCtrl.text.trim();
                            _age = int.tryParse(ageCtrl.text) ?? _age;
                            _gender = genderCtrl.text.trim();
                            _heightCm = double.tryParse(heightCtrl.text) ?? _heightCm;
                            _weightKg = double.tryParse(weightCtrl.text) ?? _weightKg;
                          });
                          // save to local session
                          final p = await SharedPreferences.getInstance();
                          await p.setString(AppSession.keyDisplayName, _name);
                          await p.setString(AppSession.keyUserEmail, _email);
                          // save to backend
                          final token = await AppSession.getToken();
                          if (token != null) {
                            await ApiService.putData(token, 'profile', {
                              'full_name': _name,
                              'age': _age,
                              'gender': _gender,
                              'height_cm': _heightCm,
                              'weight_kg': _weightKg,
                            });
                          }
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