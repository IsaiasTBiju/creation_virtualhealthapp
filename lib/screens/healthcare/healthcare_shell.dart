import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_session.dart';
import '../../api_service.dart';
import '../../widgets/app_shell_sidebar.dart';

// Clinical workspace (U-FR-6)
class HealthcareShell extends StatefulWidget {
  const HealthcareShell({super.key});
  @override
  State<HealthcareShell> createState() => _HealthcareShellState();
}

class _HealthcareShellState extends State<HealthcareShell> {
  int _nav = 0;
  int? _selectedId;
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedHistory;
  String _clinicianName = 'Clinician';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadPatients();
  }

  Future<void> _loadName() async {
    final p = await SharedPreferences.getInstance();
    final n = p.getString(AppSession.keyDisplayName);
    if (n != null && n.isNotEmpty && mounted) setState(() => _clinicianName = n);
  }

  Future<void> _loadPatients() async {
    final token = await AppSession.getToken();
    if (token == null) return;
    final data = await ApiService.getList(token, 'healthcare/patients');
    if (!mounted) return;
    setState(() {
      _patients = data.map((p) => p as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _loadPatientHistory(int patientId) async {
    setState(() => _selectedHistory = null);
    final token = await AppSession.getToken();
    if (token == null) return;
    final data = await ApiService.getMap(token, 'healthcare/patients/$patientId/history');
    if (!mounted) return;
    setState(() => _selectedHistory = data);
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
                AppShellSidebar.header(title: 'Creation', subtitle: 'Clinical workspace', brandColor: const Color(0xFF0D9488)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      AppShellSidebar.navItem(icon: Icons.space_dashboard_outlined, label: 'Overview',
                          selected: _nav == 0, accentWhenSelected: const Color(0xFF0D9488), onTap: () => setState(() => _nav = 0)),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(icon: Icons.groups_outlined, label: 'My patients',
                          selected: _nav == 1, accentWhenSelected: const Color(0xFF0D9488), onTap: () => setState(() => _nav = 1)),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(icon: Icons.chat_bubble_outline, label: 'Patient messages',
                          selected: _nav == 2, accentWhenSelected: const Color(0xFF0D9488), onTap: () => setState(() => _nav = 2)),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(icon: Icons.account_circle_outlined, label: 'Account',
                          selected: _nav == 3, accentWhenSelected: const Color(0xFF0D9488), onTap: () => setState(() => _nav = 3)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.logout, size: 22), title: const Text('Sign out'), onTap: _signOut),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 248, 249, 251),
              child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1400), child: _body())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_nav) {
      case 1: return _patientsSplit();
      case 2: return _patientMessages();
      case 3: return _accountPane();
      default: return _overview();
    }
  }

  Widget _overview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good day, $_clinicianName', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          Text('Here is a snapshot of your assigned patients.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _stat('Patients on caseload', '${_patients.length}', Icons.assignment_ind_outlined, const Color(0xFFCCFBF1), const Color(0xFF0D9488))),
              const SizedBox(width: 20),
              Expanded(child: _stat('Total registered', '${_patients.length}', Icons.people_outline, const Color(0xFFEFF6FF), const Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 28),
          if (_patients.isNotEmpty) Container(
            width: double.infinity, padding: const EdgeInsets.all(24), decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patient directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ..._patients.take(8).map((p) => _activityRow(
                  p['full_name']?.toString() ?? p['email']?.toString() ?? 'Unknown',
                  'Age: ${p['age'] ?? 'N/A'} • ${p['gender'] ?? 'N/A'}',
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFECFEFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF99F6E4))),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.teal.shade800),
                const SizedBox(width: 12),
                Expanded(child: Text('Patient data is encrypted and handled in compliance with GDPR regulations.', style: TextStyle(color: Colors.teal.shade900, fontSize: 14))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientsSplit() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFE5E7EB)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.all(20), child: Text('Patients (${_patients.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                Expanded(
                  child: _patients.isEmpty
                      ? Center(child: Text('No patients found', style: TextStyle(color: Colors.grey.shade400)))
                      : ListView.builder(
                          itemCount: _patients.length,
                          itemBuilder: (ctx, i) {
                            final p = _patients[i];
                            final id = p['user_id'] as int;
                            final name = p['full_name']?.toString() ?? p['email']?.toString() ?? 'Unknown';
                            final selected = _selectedId == id;
                            return InkWell(
                              onTap: () { setState(() => _selectedId = id); _loadPatientHistory(id); },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                color: selected ? const Color(0xFFCCFBF1) : null,
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 18, backgroundColor: const Color(0xFF0D9488).withOpacity(0.15),
                                        child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)))),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        Text('Age: ${p['age'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _selectedId == null
              ? Center(child: Text('Select a patient to view their health history', style: TextStyle(color: Colors.grey.shade400)))
              : _selectedHistory == null
                  ? const Center(child: CircularProgressIndicator())
                  : _patientDetail(),
        ),
      ],
    );
  }

  Widget _patientDetail() {
    final h = _selectedHistory!;
    final name = h['full_name']?.toString() ?? 'Patient';
    final activities = (h['activities'] as List?) ?? [];
    final biomarkers = (h['biomarkers'] as List?) ?? [];
    final wellness = (h['wellness'] as List?) ?? [];
    final meds = (h['medications'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _miniCard('Recent Activity', Icons.directions_walk,
            activities.isEmpty ? ['No activity data'] : activities.take(5).map((a) => '${a['date']} — ${a['steps']} steps, ${(a['calories'] as num).toInt()} cals').toList().cast<String>()),
          const SizedBox(height: 16),
          _miniCard('Biomarkers', Icons.monitor_heart,
            biomarkers.isEmpty ? ['No biomarker data'] : biomarkers.take(5).map((b) => '${b['type']}: ${b['value']} ${b['unit']}').toList().cast<String>()),
          const SizedBox(height: 16),
          _miniCard('Wellness', Icons.mood,
            wellness.isEmpty ? ['No wellness logs'] : wellness.take(5).map((w) => '${w['type']} — mood: ${w['mood'] ?? 'N/A'}').toList().cast<String>()),
          const SizedBox(height: 16),
          _miniCard('Medications', Icons.medication,
            meds.isEmpty ? ['No medications'] : meds.map((m) => '${m['name']} (${m['dosage'] ?? '-'}) — ${m['active'] == true ? 'Active' : 'Inactive'}').toList().cast<String>()),
        ],
      ),
    );
  }

  Widget _miniCard(String title, IconData icon, List<String> lines) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF0D9488), size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          ...lines.map((l) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $l', style: const TextStyle(fontSize: 13, height: 1.4)))),
        ],
      ),
    );
  }

  Widget _accountPane() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        final p = snap.data;
        final email = p?.getString(AppSession.keyUserEmail) ?? '';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(28), decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                _kv('Name', _clinicianName), _kv('Email', email), _kv('Role', 'Healthcare Professional'),
                const SizedBox(height: 24),
                OutlinedButton.icon(onPressed: _signOut, icon: const Icon(Icons.logout), label: const Text('Sign out')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(22), decoration: _card(),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: fg)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }

  Widget _activityRow(String text, String sub) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
    ]));
  }

  Widget _kv(String k, String v) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      SizedBox(width: 120, child: Text(k, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
      Expanded(child: Text(v)),
    ]));
  }

  // --- Patient messaging ---
  int? _msgPatientId;
  String? _msgPatientName;
  List<Map<String, dynamic>> _dmMessages = [];
  final _dmCtrl = TextEditingController();
  bool _dmLoading = false;

  Widget _patientMessages() {
    if (_msgPatientId != null) return _dmConversation();
    if (_patients.isEmpty) {
      return Center(child: Text('No patients to message', style: TextStyle(color: Colors.grey.shade400)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Messages', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Select a patient to send a secure message.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ..._patients.map((p) {
            final name = p['full_name']?.toString() ?? p['email']?.toString() ?? 'Unknown';
            final id = p['user_id'] as int;
            return InkWell(
              onTap: () { setState(() { _msgPatientId = id; _msgPatientName = name; }); _loadDm(id); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: const Color(0xFF0D9488).withOpacity(0.15),
                        child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('Tap to message', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ])),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _loadDm(int patientId) async {
    setState(() => _dmLoading = true);
    final token = await AppSession.getToken();
    if (token == null) return;
    final data = await ApiService.getList(token, 'messages?with_user=$patientId');
    if (mounted) setState(() { _dmMessages = data.map((m) => m as Map<String, dynamic>).toList(); _dmLoading = false; });
  }

  Future<void> _sendDm() async {
    if (_dmCtrl.text.trim().isEmpty || _msgPatientId == null) return;
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'messages', {'receiver_id': _msgPatientId, 'message_content': _dmCtrl.text.trim()});
    _dmCtrl.clear();
    _loadDm(_msgPatientId!);
  }

  Widget _dmConversation() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _msgPatientId = null; _msgPatientName = null; })),
              const SizedBox(width: 8),
              CircleAvatar(radius: 16, backgroundColor: const Color(0xFF0D9488).withOpacity(0.15),
                  child: Text((_msgPatientName ?? '?')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488), fontSize: 12))),
              const SizedBox(width: 10),
              Text(_msgPatientName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
        Expanded(
          child: _dmLoading
              ? const Center(child: CircularProgressIndicator())
              : _dmMessages.isEmpty
                  ? Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dmMessages.length,
                      itemBuilder: (ctx, i) {
                        final m = _dmMessages[i];
                        final isMe = m['sender_id'] != _msgPatientId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF0D9488) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                            ),
                            child: Text(m['message_content']?.toString() ?? '',
                                style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
                          ),
                        );
                      },
                    ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
          child: Row(
            children: [
              Expanded(child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                child: TextField(controller: _dmCtrl, onSubmitted: (_) => _sendDm(),
                    decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
              )),
              const SizedBox(width: 10),
              Material(color: const Color(0xFF0D9488), borderRadius: BorderRadius.circular(24),
                child: InkWell(borderRadius: BorderRadius.circular(24), onTap: _sendDm,
                    child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.send_rounded, color: Colors.white, size: 20)))),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(blurRadius: 20, offset: const Offset(0, 10), color: Colors.black.withOpacity(0.05))]);
}