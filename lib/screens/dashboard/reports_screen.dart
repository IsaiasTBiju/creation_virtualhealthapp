import 'package:flutter/material.dart';

import '../../creation_palette.dart';
import '../../api_service.dart';
import '../../app_session.dart';

class ReportsScreen extends StatefulWidget {
  final CreationPalette palette;
  const ReportsScreen({super.key, required this.palette});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final token = await AppSession.getToken();
    if (token == null) return;
    final data = await ApiService.getList(token, 'reports');
    if (!mounted) return;
    setState(() {
      _reports = data.map((r) => r as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _generate(String type) async {
    final token = await AppSession.getToken();
    if (token == null) return;
    setState(() => _generating = true);
    await ApiService.postData(token, 'reports/generate?report_type=$type', {});
    await _loadReports();
    if (!mounted) return;
    setState(() => _generating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type[0].toUpperCase()}${type.substring(1)} report generated'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color get _accent => widget.palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Reports',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Text('Generate and view your weekly or monthly health summaries.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _generateButton('Weekly', 'weekly'),
                const SizedBox(width: 10),
                _generateButton('Monthly', 'monthly'),
              ],
            ),
            const SizedBox(height: 28),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_reports.isEmpty)
              _emptyState()
            else
              ..._reports.map(_reportCard),
          ],
        ),
      ),
    );
  }

  Widget _generateButton(String label, String type) {
    return Material(
      color: _accent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _generating ? null : () => _generate(type),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_generating)
                const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else
                const Icon(Icons.summarize_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Generate $label', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.assessment_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No reports yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text('Generate your first weekly or monthly health summary above.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> report) {
    final data = report['report_data'] as Map<String, dynamic>? ?? {};
    final type = report['report_type']?.toString() ?? 'weekly';
    final generatedAt = report['generated_at']?.toString() ?? '';
    final startDate = data['start_date']?.toString() ?? '';
    final endDate = data['end_date']?.toString() ?? '';

    final steps = data['total_steps'] ?? 0;
    final cals = data['total_calories_burned'] ?? 0;
    final mins = data['total_active_minutes'] ?? 0;
    final actDays = data['activity_days'] ?? 0;
    final avgMood = data['average_mood'] ?? 0;
    final wellEntries = data['wellness_entries'] ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // report header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  type == 'monthly' ? Icons.calendar_month : Icons.date_range,
                  color: _accent, size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${type[0].toUpperCase()}${type.substring(1)} Health Report',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text('$startDate to $endDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text(_formatDate(generatedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 20),

          // stats grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _statChip(Icons.directions_walk, '$steps', 'Steps'),
              _statChip(Icons.local_fire_department, '${(cals is double) ? cals.toInt() : cals}', 'Calories'),
              _statChip(Icons.timer, '$mins min', 'Active time'),
              _statChip(Icons.calendar_today, '$actDays', 'Active days'),
              _statChip(Icons.mood, '$avgMood / 10', 'Avg mood'),
              _statChip(Icons.edit_note, '$wellEntries', 'Wellness logs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}