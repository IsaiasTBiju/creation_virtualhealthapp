import 'package:flutter/material.dart';

import '../../creation_palette.dart';

class LeaderboardRow {
  final int rank;
  final String name;
  final int points;
  final bool isYou;

  LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
    this.isYou = false,
  });
}

class FriendItem {
  final String name;
  final String handle;
  final bool following;

  FriendItem({
    required this.name,
    required this.handle,
    required this.following,
  });

  FriendItem copyWith({bool? following}) => FriendItem(
        name: name,
        handle: handle,
        following: following ?? this.following,
      );
}

class SocialHubScreen extends StatefulWidget {
  final CreationPalette palette;

  const SocialHubScreen({super.key, required this.palette});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> {
  final List<LeaderboardRow> _board = [
    LeaderboardRow(rank: 1, name: "Alex M.", points: 2840),
    LeaderboardRow(rank: 2, name: "Jordan K.", points: 2610),
    LeaderboardRow(rank: 3, name: "Sam R.", points: 2395),
    LeaderboardRow(rank: 4, name: "You", points: 2180, isYou: true),
    LeaderboardRow(rank: 5, name: "Riley P.", points: 2050),
    LeaderboardRow(rank: 6, name: "Casey L.", points: 1920),
  ];

  late List<FriendItem> _friends;

  @override
  void initState() {
    super.initState();
    _friends = [
      FriendItem(name: "Morgan Lee", handle: "@morgan_w", following: true),
      FriendItem(name: "Taylor Chen", handle: "@tchen", following: true),
      FriendItem(name: "Jamie Ortiz", handle: "@jamie_o", following: false),
      FriendItem(name: "River Singh", handle: "@river_s", following: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            _leaderboardCard(),
            const SizedBox(height: 28),
            _friendsCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Social Hub",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Leaderboard and your wellness network.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _pill("This week", Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _pill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: widget.palette.socialPillIcon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly leaderboard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Rankings based on activity points from workouts and wellness goals.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ..._board.map(_leaderRow),
        ],
      ),
    );
  }

  Widget _leaderRow(LeaderboardRow r) {
    final highlight = r.isYou;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight
            ? widget.palette.socialLeaderboardRowHighlightBg
            : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? widget.palette.socialLeaderboardBorderHighlight
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              "#${r.rank}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: highlight
                    ? widget.palette.socialLeaderboardRankHighlight
                    : const Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            child: Text(
              r.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: highlight
                    ? widget.palette.socialLeaderboardNameHighlight
                    : const Color(0xFF111827),
              ),
            ),
          ),
          Text(
            "${r.points} pts",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "People you may know",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_friends.length, (i) {
            final f = _friends[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.palette.socialAvatarBackground,
                    child: Text(
                      f.name.isNotEmpty ? f.name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: widget.palette.socialAvatarLetter,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          f.handle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _followButton(f.following, () {
                    setState(() {
                      _friends[i] =
                          f.copyWith(following: !f.following);
                    });
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _followButton(bool following, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: following
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFFF4D79), Color(0xFFFF7A18)],
                ),
          color: following ? const Color(0xFFE5E7EB) : null,
        ),
        child: Text(
          following ? "Following" : "Follow",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: following ? const Color(0xFF374151) : Colors.white,
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
