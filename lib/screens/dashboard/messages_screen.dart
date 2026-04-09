import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../creation_palette.dart';
import '../../api_service.dart';
import '../../app_session.dart';

class MessagesScreen extends StatefulWidget {
  final CreationPalette palette;
  const MessagesScreen({super.key, required this.palette});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // friends + DM state
  List<Map<String, dynamic>> _friends = [];
  int? _dmUserId;
  String? _dmUserName;
  List<Map<String, dynamic>> _dmMessages = [];
  final _dmController = TextEditingController();
  bool _loadingDm = false;

  // community chat state
  late io.Socket socket;
  final _communityController = TextEditingController();
  final _communityScroll = ScrollController();
  final List<Map<String, dynamic>> _communityMessages = [];
  String _myName = 'Me';
  String _myEmail = '';
  int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final name = await AppSession.displayName();
    final email = await AppSession.rememberedEmail();
    if (mounted) {
      setState(() {
        _myName = name ?? 'Me';
        _myEmail = email ?? '';
      });
    }
    _loadFriends();
    _initSocket();
  }

  Future<void> _loadFriends() async {
    final token = await AppSession.getToken();
    if (token == null) return;
    // load friends (mutual follows)
    final friendsData = await ApiService.getList(token, 'friends');
    // also load anyone who has messaged us (covers doctor-patient messages)
    final convosData = await ApiService.getList(token, 'messages/conversations');

    if (!mounted) return;

    // merge both lists, deduplicate by user_id
    final Map<int, Map<String, dynamic>> merged = {};
    for (final f in friendsData) {
      final id = (f['user_id'] ?? 0) as int;
      merged[id] = {'user_id': id, 'display_name': f['display_name']?.toString() ?? 'Unknown', 'subtitle': 'Friend'};
    }
    for (final c in convosData) {
      final id = (c['user_id'] ?? 0) as int;
      if (!merged.containsKey(id)) {
        final role = c['role']?.toString() ?? '';
        final label = role == 'Healthcare Professional' ? 'Healthcare Professional' : 'Contact';
        merged[id] = {'user_id': id, 'display_name': c['display_name']?.toString() ?? 'Unknown', 'subtitle': label, 'last_message': c['last_message']};
      } else {
        // update with last message info
        merged[id]!['last_message'] = c['last_message'];
      }
    }

    setState(() => _friends = merged.values.toList());
  }

  // load DM conversation with a specific friend
  Future<void> _openDm(int userId, String name) async {
    setState(() { _dmUserId = userId; _dmUserName = name; _loadingDm = true; _dmMessages = []; });
    final token = await AppSession.getToken();
    if (token == null) return;
    final data = await ApiService.getList(token, 'messages?with_user=$userId');
    if (mounted) setState(() { _dmMessages = data.map((m) => m as Map<String, dynamic>).toList(); _loadingDm = false; });
  }

  Future<void> _sendDm() async {
    if (_dmController.text.trim().isEmpty || _dmUserId == null) return;
    final token = await AppSession.getToken();
    if (token == null) return;
    await ApiService.postData(token, 'messages', {
      'receiver_id': _dmUserId,
      'message_content': _dmController.text.trim(),
    });
    _dmController.clear();
    _openDm(_dmUserId!, _dmUserName!);
  }

  // community chat socket
  void _initSocket() {
    socket = io.io('http://localhost:3001', <String, dynamic>{'transports': ['websocket'], 'autoConnect': false});
    socket.connect();
    socket.onConnect((_) {
      socket.emit('register_user', {'userId': _myEmail.isNotEmpty ? _myEmail : _myName, 'displayName': _myName});
    });
    socket.on('receive_message', (data) {
      if (!mounted) return;
      setState(() => _communityMessages.add({
        'sender': data['sender']?.toString() ?? '',
        'senderName': data['senderName']?.toString() ?? 'Unknown',
        'text': data['text']?.toString() ?? '',
        'isSystem': data['sender'] == '__system__',
        'timestamp': data['timestamp']?.toString() ?? '',
      }));
      _scrollCommunity();
    });
    socket.on('user_list', (data) {
      if (mounted) setState(() => _activeCount = data['count'] ?? 0);
    });
  }

  void _sendCommunity() {
    if (_communityController.text.trim().isEmpty) return;
    socket.emit('send_message', {
      'sender': _myEmail.isNotEmpty ? _myEmail : _myName,
      'senderName': _myName,
      'text': _communityController.text.trim(),
    });
    _communityController.clear();
  }

  void _scrollCommunity() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_communityScroll.hasClients) {
        _communityScroll.animateTo(_communityScroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  bool _isMe(String sender) => sender == _myName || (_myEmail.isNotEmpty && sender == _myEmail);

  @override
  void dispose() {
    _tabs.dispose();
    socket.dispose();
    _dmController.dispose();
    _communityController.dispose();
    _communityScroll.dispose();
    super.dispose();
  }

  Color get _accent => widget.palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
            child: Row(
              children: [
                Icon(Icons.forum_rounded, color: _accent, size: 22),
                const SizedBox(width: 14),
                const Expanded(child: Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('$_activeCount online', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                ),
              ],
            ),
          ),
          // tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: _accent,
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: _accent,
              tabs: [
                Tab(text: 'Friends (${_friends.length})'),
                const Tab(text: 'Community Chat'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabs, children: [_friendsDmTab(), _communityTab()]),
          ),
        ],
      ),
    );
  }

  // --- Friends DM tab ---
  Widget _friendsDmTab() {
    if (_dmUserId != null) return _dmConversation();
    if (_friends.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('No conversations yet', style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
        const SizedBox(height: 6),
        Text('Add friends or wait for a message from your healthcare provider', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (ctx, i) {
        final f = _friends[i];
        final name = f['display_name']?.toString() ?? 'Unknown';
        final subtitle = f['subtitle']?.toString() ?? '';
        final lastMsg = f['last_message']?.toString();
        return InkWell(
          onTap: () => _openDm((f['user_id'] ?? 0) as int, name),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: _accent.withOpacity(0.12),
                    child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: _accent))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: subtitle == 'Healthcare Professional' ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: subtitle == 'Healthcare Professional' ? const Color(0xFF15803D) : const Color(0xFF0369A1))),
                      ),
                    ],
                  ]),
                  Text(lastMsg ?? 'Tap to start chatting', style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dmConversation() {
    return Column(
      children: [
        // back + name header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _dmUserId = null; _dmUserName = null; })),
              CircleAvatar(radius: 16, backgroundColor: _accent.withOpacity(0.12),
                  child: Text((_dmUserName ?? '?')[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 12))),
              const SizedBox(width: 10),
              Text(_dmUserName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
        // messages
        Expanded(
          child: _loadingDm
              ? const Center(child: CircularProgressIndicator())
              : _dmMessages.isEmpty
                  ? Center(child: Text('No messages yet. Say hello!', style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dmMessages.length,
                      itemBuilder: (ctx, i) {
                        final m = _dmMessages[i];
                        final isMe = m['sender_id'] != _dmUserId;
                        return _dmBubble(m['message_content']?.toString() ?? '', isMe, m['sent_at']?.toString() ?? '');
                      },
                    ),
        ),
        // input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
          child: Row(
            children: [
              Expanded(child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                child: TextField(controller: _dmController, onSubmitted: (_) => _sendDm(),
                    decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
              )),
              const SizedBox(width: 10),
              Material(color: _accent, borderRadius: BorderRadius.circular(24),
                child: InkWell(borderRadius: BorderRadius.circular(24), onTap: _sendDm,
                    child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.send_rounded, color: Colors.white, size: 20)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dmBubble(String text, bool isMe, String timestamp) {
    final time = timestamp.length > 16 ? timestamp.substring(11, 16) : '';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _accent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(text, style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey.shade400)),
        ]),
      ),
    );
  }

  // --- Community chat tab ---
  Widget _communityTab() {
    return Column(
      children: [
        Expanded(
          child: _communityMessages.isEmpty
              ? Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey.shade400)))
              : ListView.builder(
                  controller: _communityScroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _communityMessages.length,
                  itemBuilder: (ctx, i) {
                    final m = _communityMessages[i];
                    if (m['isSystem'] == true) {
                      return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(m['text'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic))));
                    }
                    final isMe = _isMe(m['sender'] ?? '');
                    return _communityBubble(m['senderName'] ?? '', m['text'] ?? '', isMe);
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
                child: TextField(controller: _communityController, onSubmitted: (_) => _sendCommunity(),
                    decoration: const InputDecoration(hintText: 'Message everyone...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
              )),
              const SizedBox(width: 10),
              Material(color: _accent, borderRadius: BorderRadius.circular(24),
                child: InkWell(borderRadius: BorderRadius.circular(24), onTap: _sendCommunity,
                    child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.send_rounded, color: Colors.white, size: 20)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _communityBubble(String sender, String text, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) CircleAvatar(radius: 14, backgroundColor: _accent.withOpacity(0.12),
              child: Text(sender.isNotEmpty ? sender[0].toUpperCase() : '?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _accent))),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) Padding(padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(sender, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accent))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _accent : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(text, style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}