import 'package:flutter/material.dart';

// Bring in the model types you already use in other screens
import 'wellness_screen.dart';   // WellnessDay
import 'nutrition.dart';        // MealEntry
import 'medication.dart';       // MedicationEntry
import 'biometrics.dart';       // BiometricEntry

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final List<WellnessDay> wellnessDays;
  final List<MealEntry> todayMeals;
  final int todayCalories;
  final int todayWater;
  final List<MedicationEntry> medications;
  final List<BiometricEntry> biometrics;

  const DashboardScreen({
    super.key,
    required this.workouts,
    required this.wellnessDays,
    required this.todayMeals,
    required this.todayCalories,
    required this.todayWater,
    required this.medications,
    required this.biometrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _dailyHealthScore(),
            const SizedBox(height: 28),
            _todaySummary(),
            const SizedBox(height: 28),
            _latestBiometrics(),
            const SizedBox(height: 28),
            _recentWorkouts(),
            const SizedBox(height: 28),
            _recentMeals(),
            const SizedBox(height: 28),
            _medicationReminders(),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Here's your wellness summary:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // HEALTH SCORE
  Widget _dailyHealthScore() {
    final score = _calculateHealthScore();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C2CF3), Color(0xFFA855F7), Color(0xFFC084FC)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Health Score",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$score/100",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scoreLabel(score),
                  style: const TextStyle(
                    color: Color(0xFFBBF7D0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.yellow,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  // TODAY SUMMARY GRID
  Widget _todaySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Activity",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int columns = constraints.maxWidth < 700 ? 1 : 3;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 3.5,
              children: [
                _summaryCard(
                  icon: Icons.local_fire_department,
                  title: "Calories",
                  value: "$todayCalories kcal",
                  subtitle: "${todayMeals.length} meals logged",
                ),
                _summaryCard(
                  icon: Icons.water_drop,
                  title: "Water Intake",
                  value: "$todayWater glasses",
                  subtitle: "Goal: 8 glasses",
                ),
                _summaryCard(
                  icon: Icons.favorite,
                  title: "Workouts",
                  value: "${workouts.length}",
                  subtitle: "Total logged",
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 10),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C2CF3)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LATEST BIOMETRICS
  Widget _latestBiometrics() {
    if (biometrics.isEmpty) {
      return const SizedBox();
    }

    final b = biometrics.last;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Latest Biometrics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _bioTile("Weight", "${b.weight.toStringAsFixed(1)} kg"),
              _bioTile("Glucose", "${b.glucose} mg/dL"),
              _bioTile("Blood Pressure", "${b.systolic}/${b.diastolic}"),
              _bioTile("Temperature", "${b.temperature.toStringAsFixed(1)} °C"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bioTile(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  // RECENT WORKOUTS
  Widget _recentWorkouts() {
    if (workouts.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Workouts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: workouts.take(5).map((w) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Colors.purple.shade400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${w["type"]} • ${w["minutes"]} min • ${w["calories"]} cal",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // RECENT MEALS
  Widget _recentMeals() {
    if (todayMeals.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Meals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: todayMeals.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.type,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${m.calories} kcal",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // MEDICATION REMINDERS
  Widget _medicationReminders() {
    if (medications.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Medication Reminders",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: medications.take(5).map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${m.name} • ${m.dosage}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // HEALTH SCORE CALCULATION
  int _calculateHealthScore() {
    int score = 70;

    if (todayCalories > 0) score += 5;
    if (todayWater > 4) score += 5;
    if (workouts.isNotEmpty) score += 10;
    if (biometrics.isNotEmpty) score += 10;

    return score.clamp(0, 100);
  }

  String _scoreLabel(int score) {
    if (score >= 85) return "Great";
    if (score >= 70) return "Good";
    if (score >= 50) return "Fair";
    return "Needs Attention";
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          blurRadius: 20,
          offset: Offset(0, 10),
          color: Colors.black12,
        ),
      ],
    );
  }
}
