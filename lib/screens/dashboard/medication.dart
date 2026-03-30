import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicationEntry {
  final int id; // used for notifications
  final String name;
  final String dosage;
  final String frequency; // e.g. "Daily"
  final List<String> times; // ["09:00", "21:30"] in 24h format
  final bool remindersOn;

  MedicationEntry({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.remindersOn,
  });

  MedicationEntry copyWith({
    int? id,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    bool? remindersOn,
  }) {
    return MedicationEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      remindersOn: remindersOn ?? this.remindersOn,
    );
  }
}

class MedicationScreen extends StatefulWidget {
  final List<MedicationEntry> medications;

  final void Function(MedicationEntry med) onAddMedication;
  final void Function(int index, bool enabled) onToggleReminder;
  final void Function(int index) onDeleteMedication;

  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const MedicationScreen({
    super.key,
    required this.medications,
    required this.onAddMedication,
    required this.onToggleReminder,
    required this.onDeleteMedication,
    required this.notificationsPlugin,
  });

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController(text: "Daily");

  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        widget.medications.where((m) => m.remindersOn).length;
    final pausedCount =
        widget.medications.where((m) => !m.remindersOn).length;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _summary(activeCount, pausedCount),
            const SizedBox(height: 28),
            _medicationList(),
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
                "Medication Tracking",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Track all your medications in one place.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _primaryButton("+ Add Medication", _openAddMedicationDialog),
      ],
    );
  }

  // SUMMARY
  Widget _summary(int active, int paused) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _summaryItem("Active", active, Colors.green),
          const SizedBox(width: 40),
          _summaryItem("Paused", paused, Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "$count $label",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // LIST
  Widget _medicationList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Medications",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.medications.isEmpty)
            const Text(
              "No medications added yet.",
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ...List.generate(
            widget.medications.length,
            (i) => _medicationTile(widget.medications[i], i),
          ),
        ],
      ),
    );
  }

  Widget _medicationTile(MedicationEntry med, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: Colors.purple.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${med.dosage} • ${med.frequency}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Time: ${med.times.join(", ")}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: med.remindersOn,
            onChanged: (v) async {
              widget.onToggleReminder(index, v);
              if (v) {
                await _scheduleNotificationsForMedication(
                  widget.medications[index],
                );
              } else {
                await _cancelNotificationsForMedication(
                  widget.medications[index],
                );
              }
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await _cancelNotificationsForMedication(med);
              widget.onDeleteMedication(index);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ADD MED DIALOG
  void _openAddMedicationDialog() {
    nameController.clear();
    dosageController.clear();
    frequencyController.text = "Daily";
    selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];

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
                      "Add New Medication",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Medication Name"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Dosage"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Frequency"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: frequencyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Time(s)"),
                    const SizedBox(height: 6),
                    Column(
                      children: [
                        ...List.generate(
                          selectedTimes.length,
                          (i) => GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTimes[i],
                              );
                              if (picked != null) {
                                setLocalState(() {
                                  selectedTimes[i] = picked;
                                });
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatTimeOfDay(selectedTimes[i]),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setLocalState(() {
                              selectedTimes.add(
                                const TimeOfDay(hour: 9, minute: 0),
                              );
                            });
                          },
                          child: const Text("+ Add Time"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _primaryButton("Add Medication", () async {
                        final id =
                            DateTime.now().millisecondsSinceEpoch;

                        final timesAsStrings = selectedTimes
                            .map((t) => _formatTime24(t))
                            .toList();

                        final med = MedicationEntry(
                          id: id,
                          name: nameController.text,
                          dosage: dosageController.text,
                          frequency: frequencyController.text,
                          times: timesAsStrings,
                          remindersOn: true,
                        );

                        widget.onAddMedication(med);
                        await _scheduleNotificationsForMedication(med);

                        Navigator.pop(context);
                        setState(() {});
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

  // NOTIFICATION HELPERS

  Future<void> _scheduleNotificationsForMedication(
      MedicationEntry med) async {
    for (int i = 0; i < med.times.length; i++) {
      final timeStr = med.times[i]; // "HH:mm"
      final parts = timeStr.split(":");
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final id = _notificationIdFor(med.id, i);

      await widget.notificationsPlugin.zonedSchedule(
  id,
  "Medication Reminder",
  "${med.name} • ${med.dosage}",
  scheduled,
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'medications_channel',
      'Medications',
      channelDescription: 'Medication reminders',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  ),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
  matchDateTimeComponents: DateTimeComponents.time,
);

    }
  }

  Future<void> _cancelNotificationsForMedication(
      MedicationEntry med) async {
    for (int i = 0; i < med.times.length; i++) {
      final id = _notificationIdFor(med.id, i);
      await widget.notificationsPlugin.cancel(id);
    }
  }

  int _notificationIdFor(int medId, int index) {
    return medId.hashCode + index;
  }

  // UTILS

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  String _formatTime24(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

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
