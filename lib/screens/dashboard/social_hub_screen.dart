import 'dart:async';
import 'package:flutter/material.dart';

import '../../creation_palette.dart';
import '../../api_service.dart';
import '../../app_session.dart';

class SocialHubScreen extends StatefulWidget {
  final CreationPalette palette;
  const SocialHubScreen({super.key, required this.palette});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _discover = [];
  List<Map<String, dynamic>> _incomingRequests = [];
  bool _loading = true;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadAll());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final token = await AppSession.getToken();
      final myName = await AppSession.displayName();

      final lb = await ApiService.getLeaderboard();
      final fing = token != null ? await ApiService.getList(token, 'following') : <dynamic>[];
      final fers = token != null ? await ApiService.getList(token, 'followers') : <dynamic>[];
      final disc = token != null ? await ApiService.getList(token, 'users/search?q=') : <dynamic>[];
      final incoming = token != null ? await ApiService.getList(token, 'friend-requests/incoming') : <dynamic>[];

      if (!mounted) return;
      setState(() {
        _leaderboard = lb.map((r) => <String, dynamic>{
          'rank': r['rank'] ?? 0,
          'name': r['display_name']?.toString() ?? 'Unknown',
          'points': r['total_points'] ?? 0,
          'level': r['level'] ?? 1,
          'user_id': r['user_id'] ?? 0,
          'isYou': (r['display_name']?.toString() ?? '') == (myName ?? ''),
        }).toList();

        _following = fing.map((f) => <String, dynamic>{
          'user_id': f['user_id'] ?? 0,
          'name': f['display_name']?.toString() ?? 'Unknown',
        }).toList();

        _followers = fers.map((f) => <String, dynamic>{
          'user_id': f['user_id'] ?? 0,
          'name': f['display_name']?.toString() ?? 'Unknown',
        }).toList();

        _discover = disc.map((u) => <String, dynamic>{
          'user_id': u['user_id'] ?? 0,
          'name': u['full_name']?.toString() ?? u['email']?.toString() ?? 'Unknown',
          'email': u['email']?.toString() ?? '',
          'is_following': u['is_following'] == true,
        }).toList();

        _incomingRequests = incoming.map((r) => <String, dynamic>{
          'request_id': r['request_id'] ?? 0,
          'from_user_id': r['from_user_id'] ?? 0,
          'from_name': r['from_name']?.toString() ?? 'Unknown',
        }).toList();

        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'friend-requests', {'to_user_id': userId});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!'), behavior: SnackBarBehavior.floating),
      );
    }
    await _loadAll();
  }

  Future<void> _acceptRequest(int requestId) async {
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.putData(token, 'friend-requests/$requestId/accept');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted!'), behavior: SnackBarBehavior.floating),
      );
    }
    await _loadAll();
  }

  Future<void> _rejectRequest(int requestId) async {
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.putData(token, 'friend-requests/$requestId/reject');
    await _loadAll();
  }

  Future<void> _toggleFollow(int userId, bool currentlyFollowing) async {
    final token = await AppSession.getToken();
    if (token == null) return;
    if (currentlyFollowing) {
      await ApiService.deleteData(token, 'follow/$userId');
    } else {
      await ApiService.postData(token, 'follow', {'following_id': userId});
    }
    await _loadAll();
  }

  // tap a user to see their profile vs yours
  void _showUserProfile(int userId, String name) async {
    final token = await AppSession.getToken();
    if (token == null) return;

    final match = _leaderboard.where((r) => r['user_id'] == userId).toList();
    final theirPts = match.isNotEmpty ? match.first['points'] ?? 0 : 0;
    final theirLvl = match.isNotEmpty ? match.first['level'] ?? 1 : 1;

    final myGam = await ApiService.getMap(token, 'gamification');
    final myPts = myGam?['total_points'] ?? 0;
    final myLvl = myGam?['level'] ?? 1;
    final myBadges = await ApiService.getBadges(token);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _accent.withOpacity(0.15),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _accent)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _compareCard('You', myLvl, myPts)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.compare_arrows, color: Color(0xFF9CA3AF)),
                  ),
                  Expanded(child: _compareCard(name.split(' ').first, theirLvl, theirPts)),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Your Badges (${myBadges.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(height: 8),
              if (myBadges.isEmpty)
                const Text('No badges earned yet', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13))
              else
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: myBadges.map((b) => Chip(
                    avatar: const Icon(Icons.emoji_events, size: 16, color: Color(0xFFEAB308)),
                    label: Text(b['badge_name']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFFFFF7ED),
                  )).toList(),
                ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _compareCard(String label, int level, int points) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text('Lv $level', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _accent)),
          const SizedBox(height: 4),
          Text('$points pts', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Color get _accent => widget.palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Social Hub',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text('Connect with friends, compare progress, and climb the leaderboard.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: TabBar(
              controller: _tabs,
              labelColor: _accent,
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: _accent,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                const Tab(text: 'Leaderboard'),
                Tab(text: 'Following (${_following.length})'),
                Tab(text: 'Followers (${_followers.length})'),
                Tab(text: 'Requests (${_incomingRequests.length})'),
                const Tab(text: 'Discover'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(controller: _tabs, children: [
                    _leaderboardTab(),
                    _followingTab(),
                    _followersTab(),
                    _requestsTab(),
                    _discoverTab(),
                  ]),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardTab() {
    if (_leaderboard.isEmpty) return _emptyState('No leaderboard data yet', Icons.emoji_events);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: _leaderboard.length,
      itemBuilder: (ctx, i) {
        final r = _leaderboard[i];
        final isYou = r['isYou'] == true;
        final rank = (r['rank'] ?? 0) as int;
        return GestureDetector(
          onTap: () => _showUserProfile((r['user_id'] ?? 0) as int, r['name']?.toString() ?? 'Unknown'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isYou ? _accent.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isYou ? _accent.withOpacity(0.3) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                if (rank <= 3)
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)][rank - 1].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('$rank',
                        style: TextStyle(fontWeight: FontWeight.w800,
                            color: [const Color(0xFFB8860B), const Color(0xFF808080), const Color(0xFF8B4513)][rank - 1]))),
                  )
                else
                  SizedBox(width: 32, child: Text('#$rank', textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
                const SizedBox(width: 14),
                CircleAvatar(
                  radius: 18, backgroundColor: _accent.withOpacity(0.12),
                  child: Text((r['name']?.toString() ?? 'Unknown')[0].toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isYou ? '${r['name']} (You)' : r['name']?.toString() ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.w600, color: isYou ? _accent : const Color(0xFF111827))),
                      Text('Level ${r['level']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Text('${r['points']} pts', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _followingTab() {
    if (_following.isEmpty) return _emptyState('You\'re not following anyone yet', Icons.person_add);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: _following.length,
      itemBuilder: (ctx, i) {
        final f = _following[i];
        return _userTile(f['name']?.toString() ?? 'Unknown', (f['user_id'] ?? 0) as int,
          trailing: TextButton(
            onPressed: () => _toggleFollow((f['user_id'] ?? 0) as int, true),
            child: const Text('Unfollow', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
          ),
        );
      },
    );
  }

  Widget _followersTab() {
    if (_followers.isEmpty) return _emptyState('No followers yet', Icons.people_outline);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: _followers.length,
      itemBuilder: (ctx, i) {
        final f = _followers[i];
        final alreadyFollowing = _following.any((fol) => fol['user_id'] == f['user_id']);
        return _userTile(f['name']?.toString() ?? 'Unknown', (f['user_id'] ?? 0) as int,
          trailing: alreadyFollowing
              ? const Chip(label: Text('Following', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFE5E7EB))
              : TextButton(
                  onPressed: () => _toggleFollow((f['user_id'] ?? 0) as int, false),
                  child: Text('Follow back', style: TextStyle(color: _accent, fontSize: 13)),
                ),
        );
      },
    );
  }

  Widget _discoverTab() {
    if (_discover.isEmpty) return _emptyState('No users found', Icons.search_off);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: _discover.length,
      itemBuilder: (ctx, i) {
        final u = _discover[i];
        final isFollowing = u['is_following'] == true;
        return _userTile(u['name']?.toString() ?? 'Unknown', (u['user_id'] ?? 0) as int,
          subtitle: u['email']?.toString() ?? '',
          trailing: isFollowing
              ? const Chip(label: Text('Friends', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFDCFCE7))
              : GestureDetector(
                  onTap: () => _sendFriendRequest((u['user_id'] ?? 0) as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _accent),
                    child: const Text('Add Friend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
        );
      },
    );
  }

  Widget _requestsTab() {
    if (_incomingRequests.isEmpty) return _emptyState('No pending friend requests', Icons.person_add_disabled);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: _incomingRequests.length,
      itemBuilder: (ctx, i) {
        final r = _incomingRequests[i];
        final name = r['from_name'] as String;
        final requestId = r['request_id'] as int;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: _accent.withOpacity(0.12),
                  child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: _accent))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text('Wants to be your friend', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
              TextButton(onPressed: () => _rejectRequest(requestId),
                  child: const Text('Decline', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13))),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _acceptRequest(requestId),
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('Accept', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userTile(String name, int userId, {String? subtitle, Widget? trailing}) {
    return GestureDetector(
      onTap: () => _showUserProfile(userId, name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20, backgroundColor: _accent.withOpacity(0.12),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _accent)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}