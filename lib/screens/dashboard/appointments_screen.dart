import 'package:flutter/material.dart';

class AppointmentItem {
  final int id;
  final String title;
  final String provider;
  final DateTime startsAt;
  final String status;
  final String notes;

  AppointmentItem({
    required this.id,
    required this.title,
    required this.provider,
    required this.startsAt,
    required this.status,
    this.notes = '',
  });

  AppointmentItem copyWith({
    String? title,
    String? provider,
    DateTime? startsAt,
    String? status,
    String? notes,
  }) {
    return AppointmentItem(
      id: id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      startsAt: startsAt ?? this.startsAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class AppointmentsScreen extends StatelessWidget {
  final List<AppointmentItem> appointments;
  final void Function(AppointmentItem appt) onCreate;
  final void Function(int id, String status) onUpdateStatus;
  final void Function(int id) onDelete;

  const AppointmentsScreen({
    super.key,
    required this.appointments,
    required this.onCreate,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = appointments
        .where((a) => a.status == 'scheduled' && a.startsAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final history = appointments
        .where((a) => a.status != 'scheduled' || !a.startsAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    return Container(
      color: const Color(0xFFF3F3F3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Appointments', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Book, cancel, or reschedule healthcare visits.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
                ]),
              ),
              FilledButton.icon(
                onPressed: () => _openCreate(context),
                icon: const Icon(Icons.add),
                label: const Text('Book Appointment'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('Upcoming', upcoming),
          const SizedBox(height: 20),
          _section('History', history),
        ]),
      ),
    );
  }

  Widget _section(String title, List<AppointmentItem> list) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const Text('No appointments yet', style: TextStyle(color: Color(0xFF6B7280))),
          ...list.map((a) => _row(a)),
        ]),
      );

  Widget _row(AppointmentItem a) {
    final t =
        '${a.startsAt.year}-${a.startsAt.month.toString().padLeft(2, '0')}-${a.startsAt.day.toString().padLeft(2, '0')} ${a.startsAt.hour.toString().padLeft(2, '0')}:${a.startsAt.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${a.provider} • $t', style: const TextStyle(color: Color(0xFF6B7280))),
            ]),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') {
                onDelete(a.id);
              } else {
                onUpdateStatus(a.id, v);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'scheduled', child: Text('Mark Scheduled')),
              PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
              PopupMenuItem(value: 'cancelled', child: Text('Mark Cancelled')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: Chip(label: Text(a.status.toUpperCase())),
          ),
        ],
      ),
    );
  }

  void _openCreate(BuildContext context) {
    final titleCtrl = TextEditingController();
    final providerCtrl = TextEditingController(text: 'Dr. ');
    DateTime when = DateTime.now().add(const Duration(days: 1));
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Book Appointment'),
          content: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: providerCtrl, decoration: const InputDecoration(labelText: 'Provider')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Text('${when.toLocal()}'.substring(0, 16))),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: when,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d == null || !ctx.mounted) return;
                    final tm = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                    if (tm == null || !ctx.mounted) return;
                    setLocal(() => when = DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
                  },
                  child: const Text('Pick'),
                ),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                onCreate(
                  AppointmentItem(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: titleCtrl.text.trim().isEmpty ? 'General Consultation' : titleCtrl.text.trim(),
                    provider: providerCtrl.text.trim().isEmpty ? 'Provider' : providerCtrl.text.trim(),
                    startsAt: when,
                    status: 'scheduled',
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
