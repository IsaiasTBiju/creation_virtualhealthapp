import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BiometricEntry {
  final DateTime date;
  final double weight;
  final double height;
  final int systolic;
  final int diastolic;
  final int glucose;
  final double temperature;

  BiometricEntry({
    required this.date,
    required this.weight,
    required this.height,
    required this.systolic,
    required this.diastolic,
    required this.glucose,
    required this.temperature,
  });
}

class BiometricsScreen extends StatefulWidget {
  final List<BiometricEntry> entries;
  final void Function(BiometricEntry entry) onAddEntry;

  const BiometricsScreen({
    super.key,
    required this.entries,
    required this.onAddEntry,
  });

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final systolicCtrl = TextEditingController();
  final diastolicCtrl = TextEditingController();
  final glucoseCtrl = TextEditingController();
  final tempCtrl = TextEditingController();

  @override
  void dispose() {
    weightCtrl.dispose();
    heightCtrl.dispose();
    systolicCtrl.dispose();
    diastolicCtrl.dispose();
    glucoseCtrl.dispose();
    tempCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = widget.entries.isNotEmpty ? widget.entries.last : null;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F5F7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            if (latest != null) _summaryCards(latest),
            const SizedBox(height: 28),
            _chartSection(widget.entries),
            const SizedBox(height: 28),
            _recentEntries(widget.entries),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Biometric Tracking",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Monitor your vital health metrics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _primaryButton("+ Log Metrics", _openLogDialog),
      ],
    );
  }

  // SUMMARY CARDS
  Widget _summaryCards(BiometricEntry e) {
    final bmi = _calcBMI(e.weight, e.height);
    final bmiCategory = _bmiCategory(bmi);
    final tempStatus = _temperatureStatus(e.temperature);

    final items = [
      ("Weight", "${e.weight.toStringAsFixed(1)} kg", null),
      ("BMI", bmi.isNaN ? "--" : bmi.toStringAsFixed(1), bmiCategory),
      ("Blood Pressure", "${e.systolic}/${e.diastolic} mmHg", null),
      ("Blood Glucose", "${e.glucose} mg/dL", null),
      ("Body Temperature", "${e.temperature.toStringAsFixed(1)} °C", tempStatus),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final cardWidth = isMobile
              ? constraints.maxWidth
              : (constraints.maxWidth - 48) / 3;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: items.map((m) {
              return _metricCard(
                width: cardWidth,
                label: m.$1,
                value: m.$2,
                subtitle: m.$3,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _metricCard({
    required double width,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              )),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // CHART
  Widget _chartSection(List<BiometricEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Text(
          "No biometric data logged yet.",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final last30 = entries.length > 30
        ? entries.sublist(entries.length - 30)
        : entries;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + log count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "30-Day Trends",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                "${entries.length} Logs Recorded",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _legendDot(Colors.blue),
              const SizedBox(width: 6),
              const Text("Weight (kg)", style: TextStyle(fontSize: 13)),
              const SizedBox(width: 20),
              _legendDot(Colors.red),
              const SizedBox(width: 6),
              const Text("Blood Glucose (mg/dL)",
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (last30.length - 1).toDouble(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last30.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Log ${index + 1}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  _line(last30, (e) => e.weight, Colors.blue),
                  _line(last30, (e) => e.glucose.toDouble(), Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(
      List<BiometricEntry> data, double Function(BiometricEntry) getY, Color c) {
    return LineChartBarData(
      spots: data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), getY(e.value)))
          .toList(),
      color: c,
      isCurved: true,
      barWidth: 3,
      dotData: FlDotData(show: false),
    );
  }

  // RECENT ENTRIES TABLE
  Widget _recentEntries(List<BiometricEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Entries",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {0: FixedColumnWidth(110)},
            border: TableBorder.all(color: Color(0xFFE5E7EB), width: 1),
            children: [
              _tableHeader(),
              ...entries.reversed.map(_tableRow),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _tableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
      children: [
        _TableHeaderCell("Date"),
        _TableHeaderCell("Weight"),
        _TableHeaderCell("BP"),
        _TableHeaderCell("Glucose"),
        _TableHeaderCell("Temp"),
      ],
    );
  }

  TableRow _tableRow(BiometricEntry e) {
    final dateStr =
        "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}";

    return TableRow(
      children: [
        _tableCell(dateStr),
        _tableCell("${e.weight.toStringAsFixed(1)}kg"),
        _tableCell("${e.systolic}/${e.diastolic}"),
        _tableCell("${e.glucose}"),
        _tableCell("${e.temperature.toStringAsFixed(1)}°C"),
      ],
    );
  }

  static Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  // LOG DIALOG
  void _openLogDialog() {
    weightCtrl.clear();
    heightCtrl.clear();
    systolicCtrl.clear();
    diastolicCtrl.clear();
    glucoseCtrl.clear();
    tempCtrl.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Log Biometric Data",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your latest biometric readings.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _input("Weight (kg)", weightCtrl),
                  _input("Height (cm)", heightCtrl),

                  const SizedBox(height: 8),
                  const Text(
                    "Blood Pressure (mmHg)",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: systolicCtrl,
                          decoration: const InputDecoration(
                            labelText: "Systolic",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: diastolicCtrl,
                          decoration: const InputDecoration(
                            labelText: "Diastolic",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _input("Blood Glucose (mg/dL)", glucoseCtrl),
                  _input("Body Temperature (°C)", tempCtrl),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _primaryButton("Log Metrics", _submitEntry),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _submitEntry() {
    final entry = BiometricEntry(
      date: DateTime.now(),
      weight: double.tryParse(weightCtrl.text) ?? 0,
      height: double.tryParse(heightCtrl.text) ?? 0,
      systolic: int.tryParse(systolicCtrl.text) ?? 0,
      diastolic: int.tryParse(diastolicCtrl.text) ?? 0,
      glucose: int.tryParse(glucoseCtrl.text) ?? 0,
      temperature: double.tryParse(tempCtrl.text) ?? 0,
    );

    widget.onAddEntry(entry);
    Navigator.pop(context);
    setState(() {});
  }

  // HELPERS
  double _calcBMI(double weight, double heightCm) {
    if (weight <= 0 || heightCm <= 0) return double.nan;
    final h = heightCm / 100;
    return weight / (h * h);
  }

  String _bmiCategory(double bmi) {
    if (bmi.isNaN) return "";
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  String _temperatureStatus(double t) {
    if (t <= 0) return "";
    if (t < 36.0) return "Low";
    if (t <= 37.5) return "Normal";
    return "High";
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

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

Widget _legendDot(Color c) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: c,
      shape: BoxShape.circle,
    ),
  );
}
