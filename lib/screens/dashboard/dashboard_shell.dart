import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app_preferences.dart';
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
  }

  @override
  void dispose() {
    widget.appPrefs.removeListener(_onAppPrefsChanged);
    super.dispose();
  }

  void _onAppPrefsChanged() {
    if (mounted) setState(() {});
  }

  // FITNESS
  List<Map<String, dynamic>> workouts = [
    {"type": "Running", "date": "2025-11-21", "minutes": 23, "calories": 351},
    {"type": "HIIT", "date": "2025-11-20", "minutes": 64, "calories": 378},
    {"type": "Running", "date": "2025-11-19", "minutes": 70, "calories": 373},
  ];

  // WELLNESS
  List<WellnessDay> wellnessDays = [
    WellnessDay(
        date: DateTime.now().subtract(const Duration(days: 13)),
        energy: 6,
        stress: 4,
        mood: "Calm"),
    WellnessDay(
        date: DateTime.now().subtract(const Duration(days: 12)),
        energy: 7,
        stress: 3,
        mood: "Happy"),
    WellnessDay(
        date: DateTime.now().subtract(const Duration(days: 11)),
        energy: 5,
        stress: 5,
        mood: "Neutral"),
    WellnessDay(
        date: DateTime.now(), energy: 6, stress: 5, mood: "Tired"),
  ];

  int totalMindfulnessMinutes = 80;

  // NUTRITION
  int dailyCalorieGoal = 2000;
  int dailyWaterGoal = 8;

  int todayCalories = 0;
  int todayWater = 0;

  List<MealEntry> todayMeals = [];
  List<MealEntry> recentMeals = [];

  // MEDICATIONS
  List<MedicationEntry> medications = [];

  // BIOMETRICS
  List<BiometricEntry> biometricEntries = [];
  List<AppointmentItem> appointments = [
    AppointmentItem(
      id: 1,
      title: "Routine Checkup",
      provider: "Dr. Morgan",
      startsAt: DateTime.now().add(const Duration(days: 2, hours: 2)),
      status: "scheduled",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette =
        CreationPalette(colorBlind: widget.appPrefs.colorBlindMode);
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

      // FITNESS
      FitnessScreen(
        palette: palette,
        workouts: workouts,
        onAddWorkout: (workout) {
          setState(() => workouts.insert(0, workout));
        },
      ),

      // WELLNESS
      WellnessScreen(
        palette: palette,
        days: wellnessDays,
        totalMindfulnessMinutes: totalMindfulnessMinutes,
        onLogMood: (updatedDay) {
          setState(() {
            wellnessDays[wellnessDays.length - 1] = updatedDay;
          });
        },
        onLogMindfulness: (minutes) {
          setState(() {
            totalMindfulnessMinutes += minutes;
          });
        },
      ),

      // NUTRITION
      NutritionScreen(
        palette: palette,
        dailyCalorieGoal: dailyCalorieGoal,
        dailyWaterGoal: dailyWaterGoal,
        todayCalories: todayCalories,
        todayWater: todayWater,
        todayMeals: todayMeals,
        recentMeals: recentMeals,
        onLogMeal: (meal) {
          setState(() {
            todayMeals.add(meal);
            recentMeals.insert(0, meal);
            todayCalories += meal.calories;
          });
        },
        onLogWater: () {
          setState(() {
            todayWater += 1;
          });
        },
        onUpdateGoals: (cal, water) {
          setState(() {
            dailyCalorieGoal = cal;
            dailyWaterGoal = water;
          });
        },
      ),

      // MEDICATIONS
      MedicationScreen(
        palette: palette,
        medications: medications,
        notificationsPlugin: widget.notificationsPlugin,
        onAddMedication: (med) {
          setState(() => medications.add(med));
        },
        onToggleReminder: (index, enabled) {
          setState(() {
            medications[index] =
                medications[index].copyWith(remindersOn: enabled);
          });
        },
        onDeleteMedication: (index) {
          setState(() => medications.removeAt(index));
        },
      ),

      // BIOMETRICS
      BiometricsScreen(
        entries: biometricEntries,
        onAddEntry: (entry) {
          setState(() {
            biometricEntries.add(entry);
          });
        },
      ),

      AppointmentsScreen(
        appointments: appointments,
        onCreate: (appt) => setState(() => appointments.add(appt)),
        onUpdateStatus: (id, status) {
          setState(() {
            final i = appointments.indexWhere((a) => a.id == id);
            if (i != -1) appointments[i] = appointments[i].copyWith(status: status);
          });
        },
        onDelete: (id) => setState(() => appointments.removeWhere((a) => a.id == id)),
      ),
      ChatbotScreen(palette: palette),
      
      // --- THE FIX IS HERE ---
      MessagesScreen(palette: palette),
      // -----------------------

      SocialHubScreen(palette: palette),
      AchievementsScreen(palette: palette),
      JournalScreen(palette: palette),
      const BrainGamesScreen(),
      ProfileScreen(palette: palette),
      SettingsScreen(appPrefs: widget.appPrefs),
    ];

    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDEBAR
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              border: const Border(
                right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Creation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: palette.sidebarBrandTitle,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _navItem(Icons.dashboard, "Dashboard", 0, palette),
                        _navItem(Icons.favorite, "Fitness Tracking", 1, palette),
                        _navItem(Icons.self_improvement, "Wellness", 2, palette),
                        _navItem(Icons.restaurant, "Nutrition", 3, palette),
                        _navItem(Icons.medication, "Medications", 4, palette),
                        _navItem(Icons.monitor_heart, "Biometrics", 5, palette),
                        _navItem(Icons.calendar_month, "Appointments", 6, palette),
                        _navItem(Icons.smart_toy_outlined, "AI Companion", 7, palette),
                        _navItem(Icons.chat_bubble_outline, "Messages", 8, palette),
                        _navItem(Icons.people, "Social Hub", 9, palette),
                        _navItem(Icons.emoji_events, "Achievements", 10, palette),
                        _navItem(Icons.book, "Journal", 11, palette),
                        _navItem(Icons.videogame_asset, "Brain Games", 12, palette),
                        _navItem(Icons.person, "Profile", 13, palette),
                        _navItem(Icons.settings, "Settings", 14, palette),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 248, 249, 251),
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

  Widget _navItem(IconData icon, String label, int index, CreationPalette palette) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? palette.navSelectedBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected ? Colors.white : Colors.black,
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