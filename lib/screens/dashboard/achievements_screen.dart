import 'package:flutter/material.dart';

import '../../creation_palette.dart';
import '../../api_service.dart';
import '../../app_session.dart';

class BadgeItem {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final Color accent;

  BadgeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.accent,
  });
}

// all possible badges with icons
const Map<String, IconData> _badgeIcons = {
  "First Steps": Icons.directions_run,
  "Week Warrior": Icons.local_fire_department,
  "Century Club": Icons.stars,
  "Dedicated": Icons.military_tech,
  "Unstoppable": Icons.bolt,
};

class AchievementsScreen extends StatefulWidget {
  final CreationPalette palette;
  final Key? refreshKey; // change this to force reload

  const AchievementsScreen({super.key, required this.palette, this.refreshKey});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<BadgeItem> _badges = [];
  int _level = 1;
  int _points = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AchievementsScreen old) {
    super.didUpdateWidget(old);
    // reload when refreshKey changes (tab selected)
    if (widget.refreshKey != old.refreshKey) _loadData();
  }

  Future<void> _loadData() async {
    final token = await AppSession.getToken();
    if (token == null) return;

    // load gamification stats
    final gam = await ApiService.getMap(token, 'gamification');
    if (mounted && gam != null) {
      setState(() {
        _level = gam['level'] ?? 1;
        _points = gam['total_points'] ?? 0;
        _streak = gam['current_streak_days'] ?? 0;
      });
    }

    // load earned badges
    final earnedBadges = await ApiService.getBadges(token);
    final earnedNames = earnedBadges.map((b) => b['badge_name']?.toString() ?? '').toSet();

    // build badge list — all possible badges, mark earned ones as unlocked
    final allBadges = [
      {"name": "First Steps", "desc": "Log your first activity", "color": const Color(0xFF2563EB)},
      {"name": "Week Warrior", "desc": "Maintain a 7-day streak", "color": const Color(0xFFF97316)},
      {"name": "Century Club", "desc": "Earn 100 total points", "color": const Color(0xFF10B981)},
      {"name": "Dedicated", "desc": "Reach level 5", "color": widget.palette.accentViolet},
      {"name": "Unstoppable", "desc": "Achieve a 30-day streak", "color": const Color(0xFFEF4444)},
      {"name": "Hydration Hero", "desc": "Hit water goal 7 days in a row", "color": const Color(0xFF0EA5E9)},
      {"name": "Mindful Week", "desc": "Log mindfulness 5 times", "color": widget.palette.accentViolet},
      {"name": "Community Star", "desc": "Finish top 5 on the weekly board", "color": const Color(0xFFEAB308)},
      {"name": "Balanced Life", "desc": "Log mood + sleep + nutrition same day", "color": const Color(0xFF10B981)},
    ];

    if (mounted) {
      setState(() {
        _badges = allBadges.map((b) {
          final name = b['name'] as String;
          return BadgeItem(
            title: name,
            description: b['desc'] as String,
            icon: _badgeIcons[name] ?? Icons.emoji_events,
            unlocked: earnedNames.contains(name),
            accent: b['color'] as Color,
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _badges.where((b) => b.unlocked).length;

    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _summaryRow(unlockedCount),
            const SizedBox(height: 28),
            _weeklyChallenge(),
            const SizedBox(height: 28),
            _badgesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Achievements",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Badges, streaks, and weekly challenges.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(int unlocked) {
    // coins = 25 per badge earned
    final coins = unlocked * 25;
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(
          width: 220,
          child: _statCard("Level", "$_level", "$_points total points",
              Icons.military_tech, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
        ),
        SizedBox(
          width: 220,
          child: _statCard("Current streak", "$_streak days", "Keep it going",
              Icons.bolt, const Color(0xFFFFF7ED), const Color(0xFFF97316)),
        ),
        SizedBox(
          width: 220,
          child: _statCard("Badges earned", "$unlocked / ${_badges.length}", "Collect them all",
              Icons.workspace_premium, widget.palette.summaryIconBackground, widget.palette.accentDeepPurple),
        ),
        SizedBox(
          width: 220,
          child: _statCard("Coins", "$coins", "Earn by unlocking badges",
              Icons.monetization_on, const Color(0xFFFFF7ED), const Color(0xFFEAB308)),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color bg,
    Color iconColor,
  ) {
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChallenge() {
    // use real points progress
    final progress = _points > 0 ? (_points % 100) / 100.0 : 0.0;
    final target = (_level) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: widget.palette.brandGradientShort),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: widget.palette.brandGlowShadow,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Level up challenge", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text("Earn $target points to reach Level ${_level + 1}",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text("$_points / $target points",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgesGrid() {
    final badges = _badges;
    return Container(
      width: double.infinity,
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
            "Badge collection",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 900 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemCount: badges.length,
                itemBuilder: (context, i) => _badgeTile(badges[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(BadgeItem b) {
    final locked = !b.unlocked;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF3F4F6) : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: locked
              ? const Color(0xFFE5E7EB)
              : b.accent.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: locked ? Colors.grey.shade300 : b.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  b.icon,
                  color: locked ? Colors.grey.shade500 : b.accent,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (b.unlocked)
                const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 22)
              else
                Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 22),
            ],
          ),
          const Spacer(),
          Text(
            b.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: locked ? Colors.grey.shade500 : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            b.description,
            style: TextStyle(
              fontSize: 12,
              color: locked ? Colors.grey.shade500 : const Color(0xFF6B7280),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}