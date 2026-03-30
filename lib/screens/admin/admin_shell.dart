import 'package:flutter/material.dart';

import '../../app_session.dart';
import '../../widgets/app_shell_sidebar.dart';

class _MockUserRow {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;

  _MockUserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

/// Admin console (S-FR-5). Aggregated stats + user directory (demo data).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _nav = 0;

  late List<_MockUserRow> _users;

  @override
  void initState() {
    super.initState();
    _users = [
      _MockUserRow(
        id: 'u1',
        name: 'Alex Rivera',
        email: 'alex@example.com',
        role: 'Member',
        status: 'Active',
      ),
      _MockUserRow(
        id: 'u2',
        name: 'Dr. Morgan Vance',
        email: 'm.vance@healthsys.test',
        role: 'Healthcare professional',
        status: 'Active',
      ),
      _MockUserRow(
        id: 'u3',
        name: 'Jamie Singh',
        email: 'jamie.s@example.com',
        role: 'Member',
        status: 'Active',
      ),
      _MockUserRow(
        id: 'u4',
        name: 'Riley Chen',
        email: 'riley.c@example.com',
        role: 'Member',
        status: 'Flagged (demo)',
      ),
    ];
  }

  Future<void> _signOut() async {
    await AppSession.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  void _removeUser(_MockUserRow u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove user from platform'),
        content: Text(
          'Remove ${u.name} (${u.email}) from the directory? '
          'This demo only updates the local list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              setState(() => _users.removeWhere((e) => e.id == u.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${u.name} removed (demo directory).')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
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
                  subtitle: 'Administrator',
                  brandColor: const Color(0xFF4F46E5),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      AppShellSidebar.navItem(
                        icon: Icons.insights_outlined,
                        label: 'Overview',
                        selected: _nav == 0,
                        accentWhenSelected: const Color(0xFF4F46E5),
                        onTap: () => setState(() => _nav = 0),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.group_outlined,
                        label: 'Users',
                        selected: _nav == 1,
                        accentWhenSelected: const Color(0xFF4F46E5),
                        onTap: () => setState(() => _nav = 1),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.terminal_outlined,
                        label: 'System & audit',
                        selected: _nav == 2,
                        accentWhenSelected: const Color(0xFF4F46E5),
                        onTap: () => setState(() => _nav = 2),
                      ),
                      const SizedBox(height: 4),
                      AppShellSidebar.navItem(
                        icon: Icons.shield_outlined,
                        label: 'Privacy & GDPR',
                        selected: _nav == 3,
                        accentWhenSelected: const Color(0xFF4F46E5),
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
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _page(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page() {
    switch (_nav) {
      case 1:
        return _usersPage();
      case 2:
        return _auditPage();
      case 3:
        return _privacyPage();
      default:
        return _overviewPage();
    }
  }

  Widget _overviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform overview',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggregated, anonymised statistics (S-FR-5-2). Figures are illustrative.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _bigStat('Active accounts', '${18420 + _users.length}'),
              _bigStat('Sessions (24h)', '2,938'),
              _bigStat('API errors (24h)', '12'),
              _bigStat('Wearable sync jobs', '441'),
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
                  'Compliance snapshot',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                _bullet('Data retention policy: configurable per region (demo).'),
                _bullet('Analytics payloads: anonymised per B-FR-4.'),
                _bullet('Role-based access enforced at API boundary (when connected).'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(t, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }

  Widget _bigStat(String label, String value) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(22),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _usersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User directory',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bulk export would run against the database in production.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download_outlined, size: 20),
                label: const Text('Export CSV (demo)'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Remove users from the platform (S-FR-5-5). Demo list only.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: _card(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF3F4F6),
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('')),
                ],
                rows: _users
                    .map(
                      (u) => DataRow(
                        cells: [
                          DataCell(Text(u.name)),
                          DataCell(Text(u.email)),
                          DataCell(Text(u.role)),
                          DataCell(Text(u.status)),
                          DataCell(
                            TextButton(
                              onPressed: () => _removeUser(u),
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: Color(0xFFDC2626)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System & audit logs',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'S-FR-5-6 / S-FR-6-3: operational logs and API sync status would appear here. '
              'Sample events below.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ...[
              '[08:12:04] backup_job daily_completed status=ok',
              '[08:03:51] auth_service password_reset_requested user=***',
              '[07:55:10] wearable_sync fitbit partial_timeout retried=1',
            ].map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SelectableText(
                  line,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & GDPR controls',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'S-FR-5-3: consent records, data processing agreements, and erasure requests '
              'would be managed here with server-side workflows.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erasure queue is not connected in this build.'),
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Review erasure queue (demo)'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
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
