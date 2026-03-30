import 'package:flutter/material.dart';

class MealEntry {
  final String type; // Breakfast, Lunch, Dinner, Snack
  final String time;
  final int calories;
  final String description;

  MealEntry({
    required this.type,
    required this.time,
    required this.calories,
    required this.description,
  });
}

class NutritionScreen extends StatefulWidget {
  final int dailyCalorieGoal;
  final int dailyWaterGoal;

  final int todayCalories;
  final int todayWater;

  final List<MealEntry> todayMeals;
  final List<MealEntry> recentMeals;

  final void Function(MealEntry meal) onLogMeal;
  final void Function() onLogWater;
  final void Function(int calories, int water) onUpdateGoals;

  const NutritionScreen({
    super.key,
    required this.dailyCalorieGoal,
    required this.dailyWaterGoal,
    required this.todayCalories,
    required this.todayWater,
    required this.todayMeals,
    required this.recentMeals,
    required this.onLogMeal,
    required this.onLogWater,
    required this.onUpdateGoals,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // For goal editing
  late TextEditingController calorieGoalController;
  late TextEditingController waterGoalController;

  // For logging meals
  String selectedMealType = "Breakfast";
  final mealCaloriesController = TextEditingController(text: "500");
  final mealDescriptionController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    calorieGoalController =
        TextEditingController(text: widget.dailyCalorieGoal.toString());
    waterGoalController =
        TextEditingController(text: widget.dailyWaterGoal.toString());
  }

  @override
  void dispose() {
    calorieGoalController.dispose();
    waterGoalController.dispose();
    mealCaloriesController.dispose();
    mealDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caloriesRemaining =
        widget.dailyCalorieGoal - widget.todayCalories;

    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _goalsCard(),
            const SizedBox(height: 28),
            _todayCalories(caloriesRemaining),
            const SizedBox(height: 28),
            _waterIntake(),
            const SizedBox(height: 28),
            _todayMeals(),
            const SizedBox(height: 28),
            _recentMeals(),
          ],
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
            "Nutrition Tracking",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        _secondaryButton("AI Analyzer", () {}),
        const SizedBox(width: 12),
        _primaryButton("+ Log Meal", _openLogMealDialog),
      ],
    );
  }

  // GOALS CARD
  Widget _goalsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Goals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),

          // Calorie Goal
          const Text("Daily Calorie Goal"),
          const SizedBox(height: 6),
          TextField(
            controller: calorieGoalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // Water Goal
          const Text("Daily Water Goal (glasses)"),
          const SizedBox(height: 6),
          TextField(
            controller: waterGoalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: _primaryButton("Save Goals", () {
              widget.onUpdateGoals(
                int.tryParse(calorieGoalController.text) ?? widget.dailyCalorieGoal,
                int.tryParse(waterGoalController.text) ?? widget.dailyWaterGoal,
              );
            }),
          ),
        ],
      ),
    );
  }

  // TODAY'S CALORIES
  Widget _todayCalories(int remaining) {
    final progress = widget.todayCalories / widget.dailyCalorieGoal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Calories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "${widget.todayCalories} / ${widget.dailyCalorieGoal} kcal",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF6C2CF3),
            minHeight: 10,
          ),

          const SizedBox(height: 8),
          Text(
            "$remaining kcal remaining",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // WATER INTAKE
  Widget _waterIntake() {
    final progress = widget.todayWater / widget.dailyWaterGoal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Water Intake",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "${widget.todayWater} / ${widget.dailyWaterGoal} glasses",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF0EA5E9),
            minHeight: 10,
          ),

          const SizedBox(height: 16),
          _primaryButton("Log Water", widget.onLogWater),
        ],
      ),
    );
  }

  // TODAY'S MEALS
  Widget _todayMeals() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
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
          const SizedBox(height: 20),

          if (widget.todayMeals.isEmpty)
            const Text(
              "No meals logged yet.",
              style: TextStyle(color: Color(0xFF6B7280)),
            ),

          ...widget.todayMeals.map(_mealTile),
        ],
      ),
    );
  }

  // RECENT MEALS
  Widget _recentMeals() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Meals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),

          ...widget.recentMeals.map(_mealTile),
        ],
      ),
    );
  }

  Widget _mealTile(MealEntry meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant, color: Colors.purple.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${meal.calories} kcal",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // LOG MEAL DIALOG
  void _openLogMealDialog() {
    selectedMealType = "Breakfast";
    mealCaloriesController.text = "500";
    mealDescriptionController.text = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Log a Meal",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Meal Type"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedMealType,
                      items: ["Breakfast", "Lunch", "Dinner", "Snack"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setLocalState(() => selectedMealType = v);
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text("Time"),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setLocalState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text("Calories"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: mealCaloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text("Description"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: mealDescriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerRight,
                      child: _primaryButton("Log Meal", () {
                        final meal = MealEntry(
                          type: selectedMealType,
                          time: selectedTime.format(context),
                          calories:
                              int.tryParse(mealCaloriesController.text) ?? 0,
                          description: mealDescriptionController.text,
                        );

                        widget.onLogMeal(meal);
                        Navigator.pop(context);
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // BUTTONS
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

  Widget _secondaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  // CARD DECORATION
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
}
