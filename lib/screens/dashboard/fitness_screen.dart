import 'package:flutter/material.dart';

class FitnessScreen extends StatefulWidget {
  final List<Map<String, dynamic>> workouts;
  final Function(Map<String, dynamic>) onAddWorkout;

  const FitnessScreen({
    super.key,
    required this.workouts,
    required this.onAddWorkout,
  });

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String selectedType = "Running";
  final minutesController = TextEditingController(text: "30");
  final caloriesController = TextEditingController(text: "200");

  @override
  void dispose() {
    minutesController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Container(
    color: const Color.fromARGB(255, 243, 243, 243),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 28),
              _statsRow(),
              const SizedBox(height: 28),
              _recentWorkouts(),
            ],
          ),
        ),
      ),
    ),
  );
}


  // HEADER
  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Fitness Tracking",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        _primaryButton("+ Log Workout", _openLogWorkoutDialog),
      ],
    );
  }

  // STATS ROW
  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Total Workouts",
            widget.workouts.length.toString(),
            "All time",
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _statCard(
            "Total Minutes",
            _totalMinutes().toString(),
            "Active time",
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _statCard(
            "Total Calories",
            _totalCalories().toString(),
            "Burned",
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // RECENT WORKOUTS
  Widget _recentWorkouts() {
    return Container(
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
          const Text(
            "Recent Workouts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: widget.workouts.map((w) => _workoutTile(w)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _workoutTile(Map<String, dynamic> w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: Colors.purple.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${w["type"]} on ${w["date"]}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${w["minutes"]} min, ${w["calories"]} cal",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON
  Widget _primaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF4D79),
              Color(0xFFFF7A18),
            ],
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

  // POPUP
  void _openLogWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Log Workout Session",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Workout Type"),
                const SizedBox(height: 6),

                // Local state for dropdown inside dialog
                StatefulBuilder(
                  builder: (context, setLocalState) {
                    return DropdownButtonFormField<String>(
                      value: selectedType,
                      items: ["Running", "HIIT", "Cycling", "Walking", "Swimming"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setLocalState(() {
                          selectedType = v;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                const Text("Duration (minutes)"),
                const SizedBox(height: 6),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                const Text("Calories Burned"),
                const SizedBox(height: 6),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerRight,
                  child: _primaryButton("Log Workout", () {
                    _saveWorkout();
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SAVE WORKOUT
  void _saveWorkout() {
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    widget.onAddWorkout({
      "type": selectedType,
      "date": formattedDate,
      "minutes": int.tryParse(minutesController.text) ?? 0,
      "calories": int.tryParse(caloriesController.text) ?? 0,
    });
  }

  int _totalMinutes() {
    return widget.workouts.fold(0, (sum, w) => sum + (w["minutes"] as int));
  }

  int _totalCalories() {
    return widget.workouts.fold(0, (sum, w) => sum + (w["calories"] as int));
  }
}
