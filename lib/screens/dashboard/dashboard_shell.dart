import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app_preferences.dart';
import '../../app_session.dart';
import '../../api_service.dart';
import '../../creation_palette.dart';
import 'appointments_screen.dart';
import 'chatbot_screen.dart';
import 'dashboard_screen.dart';
import 'fitness_screen.dart';
import 'nutrition.dart';
import 'medication.dart';
import 'biometrics.dart';
import 'messages_screen.dart';
import 'wellness_screen.dart';
import 'social_hub_screen.dart';
import 'achievements_screen.dart';
import 'journal_screen.dart';
import 'brain_games_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class DashboardShell extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  final AppPreferences appPrefs;

  const DashboardShell({
    super.key,
    required this.notificationsPlugin,
    required this.appPrefs,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.appPrefs.addListener(_onAppPrefsChanged);
    _loadFromBackend();
  }

  @override
  void dispose() {
    widget.appPrefs.removeListener(_onAppPrefsChanged);
    super.dispose();
  }

  void _onAppPrefsChanged() {
    if (mounted) setState(() {});
  }

  // --- State for all screens ---

  List<Map<String, dynamic>> workouts = [];
  List<WellnessDay> wellnessDays = [];
  int totalMindfulnessMinutes = 0;

  int dailyCalorieGoal = 2000;
  int dailyWaterGoal = 8;
  int todayCalories = 0;
  int todayWater = 0;
  List<MealEntry> todayMeals = [];
  List<MealEntry> recentMeals = [];

  List<MedicationEntry> medications = [];
  List<BiometricEntry> biometricEntries = [];
  List<AppointmentItem> appointments = [];

  // track badge count to detect new badges
  int _lastBadgeCount = 0;

  // check if user earned a new badge after an action
  Future<void> _checkForNewBadges() async {
    try {
      final token = await AppSession.getToken();
      if (token == null) return;
      final badges = await ApiService.getBadges(token);
      if (badges.length > _lastBadgeCount && _lastBadgeCount > 0) {
        final newest = badges.last;
        final badgeName = newest['badge_name']?.toString() ?? 'Badge';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Achievement unlocked: $badgeName!',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                ],
              ),
              backgroundColor: const Color(0xFF1E293B),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
      _lastBadgeCount = badges.length;
    } catch (e) {
      // silently fail
    }
  }

  // --- Load data from backend on startup ---

  Future<void> _loadFromBackend() async {
    final token = await AppSession.getToken();
    if (token == null) return;

    try {
      // load activities
      final activities = await ApiService.getList(token, 'activity');
      if (mounted && activities.isNotEmpty) {
        setState(() {
          workouts = activities.map((a) {
            return <String, dynamic>{
              "type": a['source']?.toString() ?? 'manual',
              "date": a['date']?.toString() ?? '',
              "minutes": _toInt(a['active_minutes']),
              "calories": _toInt(a['calories_burned']),
            };
          }).toList();
        });
      }

      // load wellness logs
      final wellnessData = await ApiService.getList(token, 'wellness');
      if (mounted && wellnessData.isNotEmpty) {
        final moodLogs = wellnessData.where((w) => w['log_type'] == 'mood').toList();
        if (moodLogs.isNotEmpty) {
          setState(() {
            wellnessDays = moodLogs.map((w) {
              return WellnessDay(
                date: DateTime.tryParse(w['recorded_at']?.toString() ?? '') ?? DateTime.now(),
                energy: _toInt(w['value'], fallback: 5),
                stress: 5,
                mood: w['notes']?.toString() ?? 'Neutral',
              );
            }).toList();
          });
        }
      }
      // always have at least one entry
      if (wellnessDays.isEmpty) {
        setState(() {
          wellnessDays = [WellnessDay(date: DateTime.now(), energy: 5, stress: 5, mood: "Neutral")];
        });
      }

      // load biomarkers — group by date into BiometricEntry objects
      final bioData = await ApiService.getList(token, 'biomarkers');
      if (mounted && bioData.isNotEmpty) {
        // group entries by date (just the date part, not time)
        final Map<String, Map<String, double>> grouped = {};
        for (final b in bioData) {
          final dateStr = (b['recorded_at']?.toString() ?? '').split('T').first;
          grouped.putIfAbsent(dateStr, () => {});
          final metric = b['metric_type']?.toString() ?? '';
          final val = _toDouble(b['value']);
          grouped[dateStr]![metric] = val;
        }

        setState(() {
          biometricEntries = grouped.entries.map((entry) {
            final d = entry.value;
            return BiometricEntry(
              date: DateTime.tryParse(entry.key) ?? DateTime.now(),
              weight: d['weight'] ?? 70,
              height: d['height'] ?? 170,
              systolic: (d['blood_pressure_sys'] ?? 120).toInt(),
              diastolic: (d['blood_pressure_dia'] ?? 80).toInt(),
              glucose: (d['glucose'] ?? 90).toInt(),
              temperature: d['temperature'] ?? 36.6,
            );
          }).toList();
        });
      }

      // load medications
      final medData = await ApiService.getList(token, 'medications');
      if (mounted && medData.isNotEmpty) {
        setState(() {
          medications = medData.map((m) {
            final timeStr = m['reminder_time']?.toString();
            return MedicationEntry(
              id: _toInt(m['medication_id']),
              name: m['medication_name']?.toString() ?? '',
              dosage: m['dosage']?.toString() ?? '',
              frequency: m['frequency']?.toString() ?? 'Daily',
              times: (timeStr != null && timeStr.isNotEmpty) ? [timeStr] : ['09:00'],
              remindersOn: m['is_active'] == true,
            );
          }).toList();
        });
      }

      // load appointments
      final apptData = await ApiService.getList(token, 'appointments');
      if (mounted && apptData.isNotEmpty) {
        setState(() {
          appointments = apptData.map((a) {
            final dateStr = a['appointment_date']?.toString() ?? '';
            final timeStr = a['appointment_time']?.toString() ?? '00:00';
            // parse time parts safely
            final timeParts = timeStr.split(':');
            final hour = int.tryParse(timeParts.isNotEmpty ? timeParts[0] : '0') ?? 0;
            final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
            final baseDate = DateTime.tryParse(dateStr) ?? DateTime.now();
            final startsAt = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);

            return AppointmentItem(
              id: _toInt(a['appointment_id']),
              title: a['appointment_type']?.toString() ?? 'Appointment',
              provider: 'Doctor',
              startsAt: startsAt,
              status: a['status']?.toString() ?? 'scheduled',
              notes: a['notes']?.toString() ?? '',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    }

    // load initial badge count (no notification on first load)
    await _checkForNewBadges();
  }

  // safe type helpers
  int _toInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  double _toDouble(dynamic val, {double fallback = 0.0}) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  // --- API-connected callbacks ---

  Future<void> _addWorkout(Map<String, dynamic> workout) async {
    setState(() => workouts.insert(0, workout));
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'activity', {
      'date': workout['date'] ?? DateTime.now().toIso8601String().split('T')[0],
      'steps': 0,
      'calories_burned': (workout['calories'] ?? 0).toDouble(),
      'active_minutes': workout['minutes'] ?? 0,
      'source': workout['type'] ?? 'manual',
    });
    _checkForNewBadges();
  }

  Future<void> _logWellness(WellnessDay day) async {
    setState(() {
      wellnessDays[wellnessDays.length - 1] = day;
    });
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'wellness', {
      'log_type': 'mood',
      'value': day.energy.toDouble(),
      'mood_rating': day.energy,
      'notes': day.mood,
    });
    _checkForNewBadges();
  }

  Future<void> _addBiomarker(BiometricEntry entry) async {
    setState(() => biometricEntries.add(entry));
    final token = await AppSession.getToken();
    if (token == null) return;
    // log each metric type
    await ApiService.postData(token, 'biomarkers', {
      'metric_type': 'weight', 'value': entry.weight, 'unit': 'kg',
    });
    await ApiService.postData(token, 'biomarkers', {
      'metric_type': 'blood_pressure_sys', 'value': entry.systolic.toDouble(), 'unit': 'mmHg',
    });
    await ApiService.postData(token, 'biomarkers', {
      'metric_type': 'glucose', 'value': entry.glucose.toDouble(), 'unit': 'mg/dL',
    });
    _checkForNewBadges();
  }

  Future<void> _addMedication(MedicationEntry med) async {
    setState(() => medications.add(med));
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'medications', {
      'medication_name': med.name,
      'dosage': med.dosage,
      'frequency': med.frequency,
      'reminder_time': med.times.isNotEmpty ? med.times.first : null,
      'is_active': true,
    });
  }

  Future<void> _addAppointment(AppointmentItem appt) async {
    setState(() => appointments.add(appt));
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'appointments', {
      'appointment_date': appt.startsAt.toIso8601String().split('T')[0],
      'appointment_time': '${appt.startsAt.hour.toString().padLeft(2, '0')}:${appt.startsAt.minute.toString().padLeft(2, '0')}',
      'appointment_type': appt.title,
      'notes': appt.notes,
    });
  }

  Future<void> _logMeal(MealEntry meal) async {
    setState(() {
      todayMeals.add(meal);
      recentMeals.insert(0, meal);
      todayCalories += meal.calories;
    });
    // nutrition is local-only for now, could wire to wellness endpoint
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'wellness', {
      'log_type': 'nutrition',
      'value': meal.calories.toDouble(),
      'unit': 'kcal',
      'notes': '${meal.type}: ${meal.description}',
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = CreationPalette(colorBlind: widget.appPrefs.colorBlindMode);
    final pages = [
      DashboardScreen(
        palette: palette,
        workouts: workouts,
        wellnessDays: wellnessDays,
        todayMeals: todayMeals,
        todayCalories: todayCalories,
        todayWater: todayWater,
        medications: medications,
        biometrics: biometricEntries,
        onOpenAppointments: () => setState(() => selectedIndex = 6),
      ),

      FitnessScreen(
        palette: palette,
        workouts: workouts,
        onAddWorkout: _addWorkout,
      ),

      WellnessScreen(
        palette: palette,
        days: wellnessDays,
        totalMindfulnessMinutes: totalMindfulnessMinutes,
        onLogMood: _logWellness,
        onLogMindfulness: (minutes) {
          setState(() => totalMindfulnessMinutes += minutes);
        },
      ),

      NutritionScreen(
        palette: palette,
        dailyCalorieGoal: dailyCalorieGoal,
        dailyWaterGoal: dailyWaterGoal,
        todayCalories: todayCalories,
        todayWater: todayWater,
        todayMeals: todayMeals,
        recentMeals: recentMeals,
        onLogMeal: _logMeal,
        onLogWater: () {
          setState(() => todayWater += 1);
        },
        onUpdateGoals: (cal, water) {
          setState(() {
            dailyCalorieGoal = cal;
            dailyWaterGoal = water;
          });
        },
      ),

      MedicationScreen(
        palette: palette,
        medications: medications,
        notificationsPlugin: widget.notificationsPlugin,
        onAddMedication: _addMedication,
        onToggleReminder: (index, enabled) {
          setState(() {
            medications[index] = medications[index].copyWith(remindersOn: enabled);
          });
        },
        onDeleteMedication: (index) {
          setState(() => medications.removeAt(index));
        },
      ),

      BiometricsScreen(
        entries: biometricEntries,
        onAddEntry: _addBiomarker,
      ),

      AppointmentsScreen(
        appointments: appointments,
        onCreate: _addAppointment,
        onUpdateStatus: (id, status) {
          setState(() {
            final i = appointments.indexWhere((a) => a.id == id);
            if (i != -1) appointments[i] = appointments[i].copyWith(status: status);
          });
        },
        onDelete: (id) => setState(() => appointments.removeWhere((a) => a.id == id)),
      ),
      ChatbotScreen(palette: palette),
      MessagesScreen(palette: palette),
      SocialHubScreen(palette: palette),
      AchievementsScreen(palette: palette, refreshKey: ValueKey(selectedIndex == 10 ? DateTime.now().millisecondsSinceEpoch : 0)),
      JournalScreen(palette: palette),
      const BrainGamesScreen(),
      ReportsScreen(palette: palette),
      ProfileScreen(palette: palette),
      SettingsScreen(appPrefs: widget.appPrefs),
    ];

    return Scaffold(
      body: Row(
        children: [
          // sidebar
          Container(
            width: 270,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1B2E), Color(0xFF2D2640)],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // brand
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.favorite, color: palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFFA78BFA), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text("Creation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // user card
                FutureBuilder<String?>(
                  future: AppSession.displayName(),
                  builder: (ctx, snap) {
                    final name = snap.data ?? 'User';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFA78BFA).withOpacity(0.3),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                const Text('Wellness member', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // nav items
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _navLabel('Main'),
                        _navItem(Icons.dashboard_rounded, "Dashboard", 0, palette),
                        _navItem(Icons.favorite_rounded, "Fitness", 1, palette),
                        _navItem(Icons.self_improvement, "Wellness", 2, palette),
                        _navItem(Icons.restaurant_rounded, "Nutrition", 3, palette),
                        const SizedBox(height: 8),
                        _navLabel('Health'),
                        _navItem(Icons.medication_rounded, "Medications", 4, palette),
                        _navItem(Icons.monitor_heart_rounded, "Biometrics", 5, palette),
                        _navItem(Icons.calendar_month_rounded, "Appointments", 6, palette),
                        _navItem(Icons.assessment_rounded, "Health Reports", 13, palette),
                        const SizedBox(height: 8),
                        _navLabel('Social'),
                        _navItem(Icons.smart_toy_rounded, "AI Companion", 7, palette),
                        _navItem(Icons.chat_bubble_rounded, "Messages", 8, palette),
                        _navItem(Icons.people_rounded, "Social Hub", 9, palette),
                        _navItem(Icons.emoji_events_rounded, "Achievements", 10, palette),
                        const SizedBox(height: 8),
                        _navLabel('Personal'),
                        _navItem(Icons.book_rounded, "Journal", 11, palette),
                        _navItem(Icons.videogame_asset_rounded, "Brain Games", 12, palette),
                        _navItem(Icons.person_rounded, "Profile", 14, palette),
                        _navItem(Icons.settings_rounded, "Settings", 15, palette),
                      ],
                    ),
                  ),
                ),
                // sign out
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () async {
                      await AppSession.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
                          SizedBox(width: 12),
                          Text('Sign out', style: TextStyle(color: Colors.white38, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FB),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: IndexedStack(
                    index: selectedIndex,
                    sizing: StackFit.expand,
                    children: pages,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 16, 6),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white24, letterSpacing: 1)),
    );
  }

  Widget _navItem(IconData icon, String label, int index, CreationPalette palette) {
    final isSelected = selectedIndex == index;
    final accent = palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFFA78BFA);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: accent.withOpacity(0.3), width: 1) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? accent : Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}