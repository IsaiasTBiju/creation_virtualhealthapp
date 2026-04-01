import 'package:flutter/material.dart';

import '../../app_preferences.dart';
import '../../app_session.dart';

class SettingsScreen extends StatefulWidget {
  final AppPreferences appPrefs;
  const SettingsScreen({super.key, required this.appPrefs});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailDigest = false;
  bool _appointmentAlerts = true;
  bool _medicationAlerts = true;

  String _profileVisibility = "Friends";
  bool _showActivity = true;

  bool _highContrast = false;
  double _textScale = 1.0;
  bool _colorBlindMode = false;

  @override
  void initState() {
    super.initState();
    _highContrast = widget.appPrefs.highContrast;
    _textScale = widget.appPrefs.textScale;
    _colorBlindMode = widget.appPrefs.colorBlindMode;
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
            _section(
              "Notifications",
              Icons.notifications_outlined,
              [
                _toggleTile(
                  "Push notifications",
                  "Reminders for goals and social activity",
                  _pushNotifications,
                  (v) => setState(() => _pushNotifications = v),
                ),
                _toggleTile(
                  "Weekly email digest",
                  "Summary of your wellness trends",
                  _emailDigest,
                  (v) => setState(() => _emailDigest = v),
                ),
                _toggleTile(
                  "Appointment alerts",
                  "Before upcoming bookings",
                  _appointmentAlerts,
                  (v) => setState(() => _appointmentAlerts = v),
                ),
                _toggleTile(
                  "Medication reminders",
                  "Synced with Medications tab",
                  _medicationAlerts,
                  (v) => setState(() => _medicationAlerts = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _section(
              "Privacy",
              Icons.lock_outline,
              [
                _dropdownTile(
                  "Profile visibility",
                  "Who can see your profile",
                  _profileVisibility,
                  const ["Public", "Friends", "Private"],
                  (v) => setState(() => _profileVisibility = v),
                ),
                _toggleTile(
                  "Share activity on leaderboard",
                  "Display your first name and points",
                  _showActivity,
                  (v) => setState(() => _showActivity = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _section(
              "Accessibility",
              Icons.accessibility_new,
              [
                _toggleTile(
                  "High contrast",
                  "Stronger borders and text",
                  _highContrast,
                  (v) async {
                    setState(() => _highContrast = v);
                    await widget.appPrefs.setHighContrast(v);
                  },
                ),
                _toggleTile(
                  "Colour-blind friendly palette",
                  "Adjusts charts and status colours",
                  _colorBlindMode,
                  (v) async {
                    setState(() => _colorBlindMode = v);
                    await widget.appPrefs.setColorBlindMode(v);
                  },
                ),
                _sliderTile(),
              ],
            ),
            const SizedBox(height: 24),
            _section(
              "Account",
              Icons.logout,
              [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Sign out",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "End this session on this device",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await AppSession.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _dataCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Notifications, privacy, and accessibility preferences.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        value: value,
        activeThumbColor: const Color(0xFF7C3AED),
        activeTrackColor: const Color(0xFF7C3AED).withValues(alpha: 0.45),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: options
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e)),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _sliderTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Text size",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              "${(_textScale * 100).round()}%",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6),
            thumbColor: const Color(0xFF7C3AED),
            overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
          ),
          child: Slider(
            min: 0.85,
            max: 1.35,
            divisions: 10,
            value: _textScale,
            onChanged: (v) async {
              setState(() => _textScale = v);
              await widget.appPrefs.setTextScale(v);
            },
          ),
        ),
        Text(
          "Preview: adjust how large labels appear in the app.",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _dataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Data & account",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Export or delete your data in line with GDPR-style controls. "
            "Connected backend features will appear here in a future release.",
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _outlineButton("Export data (CSV)"),
              _outlineButton("Delete account", danger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outlineButton(String label, {bool danger = false}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor:
            danger ? const Color(0xFFDC2626) : const Color(0xFF374151),
        side: BorderSide(
          color: danger ? const Color(0xFFFECACA) : const Color(0xFFD1D5DB),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
