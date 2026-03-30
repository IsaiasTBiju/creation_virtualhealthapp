import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_session.dart';
import '../../data/mock_clinical_data.dart';
import '../../widgets/app_shell_sidebar.dart';

/// Clinical workspace (U-FR-6). Mock data only — no backend.
class HealthcareShell extends StatefulWidget {
  const HealthcareShell({super.key});

  @override
  State<HealthcareShell> createState() => _HealthcareShellState();
}

class _HealthcareShellState extends State<HealthcareShell> {
  int _nav = 0;
  String? _selectedId;
  late List<MockPatient> _patients;

  String _clinicianName = 'Clinician';

  @override
  void initState() {
    super.initState();
    _patients = kMockPatientsSeed
        .map(
          (p) => p.copyWith(
            diagnoses: List<String>.from(p.diagnoses),
            activeMedications: List<String>.from(p.activeMedications),
          ),
        )
        .toList();
    _loadName();
  }

  Future<void> _loadName() async {
    final p = await SharedPreferences.getInstance();
    final n = p.getString(AppSession.keyDisplayName);
    if (n != null && n.isNotEmpty && mounted) {
      setState(() => _clinicianName = n);
    }
  }

  MockPatient? get _selected {
    if (_selectedId == null) return null;
    for (final p in _patients) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  Future<void> _signOut() async {
    await AppSession.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 268,
            decoration: AppShellSidebar.panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShellSidebar.header(
                  title: 'Creation',
                  subtitle: 'Clinical workspace',
                  brandColor: const Color(0xFF0D9488),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      AppShellSidebar.navItem(
                        icon: Icons.space_dashboard_outlined,
                        label: 'Overview',
                        selected: _nav == 0,
                        accentWhenSelected: const Color(0xFF0D9488),
                        onTap: () => setState(() => _nav = 0),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.groups_outlined,
                        label: 'My patients',
                        selected: _nav == 1,
                        accentWhenSelected: const Color(0xFF0D9488),
                        onTap: () => setState(() => _nav = 1),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Messages',
                        selected: _nav == 2,
                        accentWhenSelected: const Color(0xFF0D9488),
                        onTap: () => setState(() => _nav = 2),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.account_circle_outlined,
                        label: 'Account',
                        selected: _nav == 3,
                        accentWhenSelected: const Color(0xFF0D9488),
                        onTap: () => setState(() => _nav = 3),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, size: 22),
                  title: const Text('Sign out'),
                  onTap: _signOut,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 248, 249, 251),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: _body(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_nav) {
      case 1:
        return _patientsSplit();
      case 2:
        return _messagesPlaceholder();
      case 3:
        return _accountPane();
      default:
        return _overview();
    }
  }

  Widget _overview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good day, $_clinicianName',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Here is a snapshot of your assigned patients and follow-ups.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _stat(
                  'Patients on caseload',
                  '${_patients.length}',
                  Icons.assignment_ind_outlined,
                  const Color(0xFFCCFBF1),
                  const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _stat(
                  'Follow-ups this week',
                  '12',
                  Icons.event_note_outlined,
                  const Color(0xFFEFF6FF),
                  const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _stat(
                  'Abnormal vitals (demo)',
                  '2',
                  Icons.warning_amber_rounded,
                  const Color(0xFFFFF7ED),
                  const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _activityRow('Lab results imported for ${ _patients[1].fullName }', 'Yesterday'),
                _activityRow('Care plan updated — ${_patients[0].fullName}', '2 days ago'),
                _activityRow('Message thread: ${_patients[2].fullName}', 'Today'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFEFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.teal.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This workspace is a demonstration. No data is transmitted or stored on a server.',
                    style: TextStyle(
                      color: Colors.teal.shade900,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(String text, String when) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Text(
            when,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String title,
    String value,
    IconData icon,
    Color bg,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientsSplit() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Container(
              decoration: _card(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _patients.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Builder(
                      builder: (_) {
                        final p = _patients[i];
                        final sel = p.id == _selectedId;
                        return ListTile(
                          selected: sel,
                          selectedTileColor: const Color(0xFFCCFBF1)
                              .withValues(alpha: 0.5),
                          title: Text(
                            p.fullName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${p.age} · ${p.mrn}'),
                          onTap: () =>
                              setState(() => _selectedId = p.id),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(child: _patientDetailPanel()),
        ],
      ),
    );
  }

  Widget _patientDetailPanel() {
    final p = _selected;
    if (p == null) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(48),
        decoration: _card(),
        child: Text(
          'Select a patient to view history, diagnoses, and medications.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${p.age} yrs · ${p.gender} · ${p.mrn}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  p.lastVisitLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  p.conditionsSummary,
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _miniCard(
                  'Trends & vitals',
                  [
                    'Avg steps (7d): ${p.avgStepsWeek}',
                    'Last BP: ${p.bpLast}',
                    'Last glucose: ${p.glucoseLast}',
                  ],
                  Icons.monitor_heart_outlined,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _miniCard(
                  'Diagnoses',
                  p.diagnoses,
                  Icons.medical_information_outlined,
                  trailing: TextButton.icon(
                    onPressed: () => _addDiagnosis(p),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _miniCard(
            'Prescriptions & orders',
            p.activeMedications,
            Icons.medication_outlined,
            trailing: TextButton.icon(
              onPressed: () => _prescribeMed(p),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Prescribe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(
    String title,
    List<String> lines,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0D9488)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(l, style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addDiagnosis(MockPatient p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add diagnosis (demo)'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'ICD-style label',
            hintText: 'e.g. I10 Essential hypertension',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              setState(() {
                final i = _patients.indexWhere((e) => e.id == p.id);
                if (i >= 0) {
                  final u = List<String>.from(_patients[i].diagnoses)..add(t);
                  _patients[i] = _patients[i].copyWith(diagnoses: u);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _prescribeMed(MockPatient p) {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Prescribe medication (demo)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Medication'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: doseCtrl,
              decoration: const InputDecoration(labelText: 'Sig / dose'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isEmpty) return;
              final d = doseCtrl.text.trim();
              final line = d.isEmpty ? n : '$n — $d';
              setState(() {
                final i = _patients.indexWhere((e) => e.id == p.id);
                if (i >= 0) {
                  final u = List<String>.from(_patients[i].activeMedications)
                    ..add(line);
                  _patients[i] = _patients[i].copyWith(activeMedications: u);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add to chart'),
          ),
        ],
      ),
    );
  }

  Widget _messagesPlaceholder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure messaging',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Real-time messaging (U-FR-7) will connect here once the messaging service is implemented. '
              'For now this panel demonstrates navigation and layout only.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ...['Jordan Lee', 'Sam Okonkwo', 'Riley Chen'].map(
              (n) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(n),
                subtitle: const Text('No new messages (demo)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountPane() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        final p = snap.data;
        final email = p?.getString(AppSession.keyUserEmail) ?? '—';
        final role = p?.getString(AppSession.keyUserRole) ?? AppSession.roleHealthcareProfessional;
        final roleLabel = role == AppSession.roleHealthcareProfessional
            ? 'Healthcare professional'
            : role;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),
                _kv('Name', _clinicianName),
                _kv('Email', email),
                _kv('Role', roleLabel),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 20,
          offset: const Offset(0, 10),
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ],
    );
  }
}
