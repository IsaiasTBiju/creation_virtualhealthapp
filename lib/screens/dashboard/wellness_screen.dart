import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../creation_palette.dart';

class WellnessDay {
  final DateTime date;
  final int energy; // 0–10
  final int stress; // 0–10
  final String mood;

  WellnessDay({
    required this.date,
    required this.energy,
    required this.stress,
    required this.mood,
  });

  WellnessDay copyWith({
    DateTime? date,
    int? energy,
    int? stress,
    String? mood,
  }) {
    return WellnessDay(
      date: date ?? this.date,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      mood: mood ?? this.mood,
    );
  }
}

class WellnessScreen extends StatefulWidget {
  final CreationPalette palette;
  final List<WellnessDay> days;
  final int totalMindfulnessMinutes;

  final void Function(WellnessDay updatedDay) onLogMood;
  final void Function(int minutes) onLogMindfulness;

  const WellnessScreen({
    super.key,
    required this.palette,
    required this.days,
    required this.totalMindfulnessMinutes,
    required this.onLogMood,
    required this.onLogMindfulness,
  });

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  // Mood options (Option A)
  final List<String> moods = const [
    "Happy",
    "Calm",
    "Energized",
    "Neutral",
    "Stressed",
    "Tired",
    "Sad",
    "Angry",
    "Anxious",
    "Excited",
  ];

  String _selectedMood = "Neutral";
  double _energySlider = 5;
  double _stressSlider = 5;
  double _mindfulnessSlider = 10;

  WellnessDay get _today {
    // assume last entry is "today"
    return widget.days.isNotEmpty
        ? widget.days.last
        : WellnessDay(
            date: DateTime.now(),
            energy: 5,
            stress: 5,
            mood: "Neutral",
          );
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = _today.mood;
    final totalMindfulness = widget.totalMindfulnessMinutes;

    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _topStatsRow(currentMood, totalMindfulness),
            const SizedBox(height: 28),
            _energyStressTrends(),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Wellness Tracking",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Monitor your emotional and mental health.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _secondaryButton("Log Mindfulness", _openLogMindfulnessDialog),
        const SizedBox(width: 12),
        _primaryButton("+ Log Mood", _openLogMoodDialog),
      ],
    );
  }

  // TOP STATS
  Widget _topStatsRow(String currentMood, int totalMindfulnessMinutes) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: "Total Mindfulness Minutes",
            value: "$totalMindfulnessMinutes",
            subtitle: "All time",
            icon: Icons.self_improvement,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _statCard(
            title: "Current Mood",
            value: currentMood,
            subtitle: "Today",
            icon: Icons.favorite,
            iconBg: const Color(0xFFFFE4E6),
            iconColor: const Color(0xFFFB7185),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

  // ENERGY & STRESS TRENDS
  Widget _energyStressTrends() {
    if (widget.days.isEmpty) {
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
        child: const Text(
          "No wellness data yet. Log your mood to start tracking.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    final energyData = widget.days.map((d) => d.energy.toDouble()).toList();
    final stressData = widget.days.map((d) => d.stress.toDouble()).toList();

    final maxY = [
      ...energyData,
      ...stressData,
    ].reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxY * 1.2).clamp(1, 10.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            "Energy & Stress Trends",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Track how your energy and stress change over time.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (energyData.length - 1).toDouble(),
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMaxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: (energyData.length / 4)
                          .floorToDouble()
                          .clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= energyData.length) {
                          return const SizedBox.shrink();
                        }
                        final day = widget.days[index].date.day;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "D$day",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: chartMaxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE5E7EB)),
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      energyData.length,
                      (i) => FlSpot(i.toDouble(), energyData[i]),
                    ),
                    isCurved: true,
                    color: const Color(0xFF22C55E), // green
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF22C55E).withOpacity(0.25),
                          const Color(0xFF22C55E).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      stressData.length,
                      (i) => FlSpot(i.toDouble(), stressData[i]),
                    ),
                    isCurved: true,
                    color: const Color(0xFFEF4444), // red
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.25),
                          const Color(0xFFEF4444).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  // LOG MOOD DIALOG
  void _openLogMoodDialog() {
    final today = _today;
    _selectedMood = today.mood;
    _energySlider = today.energy.toDouble();
    _stressSlider = today.stress.toDouble();

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
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How are you feeling?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Log your current mood, energy, and stress level.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Mood",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: moods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final mood = moods[index];
                          final isSelected = mood == _selectedMood;
                          return GestureDetector(
                            onTap: () {
                              setLocalState(() {
                                _selectedMood = mood;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.palette.wellnessMoodSelectedFill
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? widget.palette.wellnessMoodSelectedFill
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  mood,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Energy Level",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_energySlider.toInt()}/10",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _energySlider,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _energySlider.toInt().toString(),
                      onChanged: (v) {
                        setLocalState(() {
                          _energySlider = v;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Stress Level",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_stressSlider.toInt()}/10",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _stressSlider,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _stressSlider.toInt().toString(),
                      activeColor: const Color(0xFFEF4444),
                      onChanged: (v) {
                        setLocalState(() {
                          _stressSlider = v;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: _primaryButton("Log Mood", () {
                        final updated = today.copyWith(
                          mood: _selectedMood,
                          energy: _energySlider.toInt(),
                          stress: _stressSlider.toInt(),
                        );
                        widget.onLogMood(updated);
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

  // LOG MINDFULNESS DIALOG
  void _openLogMindfulnessDialog() {
    _mindfulnessSlider = 10;

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
                      "Log Mindfulness Session",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mindfulness can be meditation, breathing exercises, or simply being present.\nEven a few minutes can help reduce stress and improve focus.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Duration (minutes)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_mindfulnessSlider.toInt()} min",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _mindfulnessSlider,
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: _mindfulnessSlider.toInt().toString(),
                      onChanged: (v) {
                        setLocalState(() {
                          _mindfulnessSlider = v;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: _primaryButton("Log Mindfulness", () {
                        widget.onLogMindfulness(_mindfulnessSlider.toInt());
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
}
