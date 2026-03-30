import 'package:flutter/material.dart';

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

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static final List<BadgeItem> _badges = [
    BadgeItem(
      title: "First Steps",
      description: "Complete your first workout",
      icon: Icons.directions_run,
      unlocked: true,
      accent: const Color(0xFF2563EB),
    ),
    BadgeItem(
      title: "Hydration Hero",
      description: "Hit water goal 7 days in a row",
      icon: Icons.water_drop,
      unlocked: true,
      accent: const Color(0xFF0EA5E9),
    ),
    BadgeItem(
      title: "Mindful Week",
      description: "Log mindfulness 5 times",
      icon: Icons.self_improvement,
      unlocked: true,
      accent: const Color(0xFF8B5CF6),
    ),
    BadgeItem(
      title: "Streak Master",
      description: "Maintain a 14-day activity streak",
      icon: Icons.local_fire_department,
      unlocked: false,
      accent: const Color(0xFFF97316),
    ),
    BadgeItem(
      title: "Community Star",
      description: "Finish top 5 on the weekly board",
      icon: Icons.emoji_events,
      unlocked: false,
      accent: const Color(0xFFEAB308),
    ),
    BadgeItem(
      title: "Balanced Life",
      description: "Log mood + sleep + nutrition same day",
      icon: Icons.balance,
      unlocked: false,
      accent: const Color(0xFF10B981),
    ),
  ];

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
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Level",
            "12",
            "Wellness tier",
            Icons.military_tech,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _statCard(
            "Current streak",
            "7 days",
            "Keep it going",
            Icons.bolt,
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _statCard(
            "Badges earned",
            "$unlocked / ${_badges.length}",
            "Collect them all",
            Icons.workspace_premium,
            const Color(0xFFF3E8FF),
            const Color(0xFF9333EA),
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C2CF3), Color(0xFFA855F7)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: const Color(0xFF6C2CF3).withOpacity(0.35),
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
                const Text(
                  "Weekly challenge",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Complete 150 active minutes before Sunday",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.62,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "93 / 150 minutes",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgesGrid() {
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
                itemCount: _badges.length,
                itemBuilder: (context, i) => _badgeTile(_badges[i]),
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
