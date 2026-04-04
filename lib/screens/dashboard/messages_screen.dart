import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../creation_palette.dart';
import '../../app_session.dart';

/// A single chat message (from anyone, including system).
class _ChatMessage {
  final String id;
  final String sender;      // unique user id / email
  final String senderName;  // display name
  final String text;
  final DateTime timestamp;
  final bool isSystem;

  _ChatMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isSystem = false,
  });
}

class MessagesScreen extends StatefulWidget {
  final CreationPalette palette;
  const MessagesScreen({super.key, required this.palette});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late io.Socket socket;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final List<_ChatMessage> _messages = [];

  String _myName = 'Me';
  String _myEmail = '';
  int _activeCount = 0;
  List<Map<String, String>> _activeUsers = [];
  String? _typingUser; // who is currently typing
  Timer? _typingTimer;
  bool _iAmTyping = false;

  // ── Lifecycle ───────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final name = await AppSession.displayName();
    final prefs = await AppSession.rememberedEmail();
    if (mounted) {
      setState(() {
        _myName = (name != null && name.isNotEmpty) ? name : 'Me';
        _myEmail = prefs ?? '';
      });
    }
    _initSocket();
  }

  void _initSocket() {
    socket = io.io('http://localhost:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      // Tell the server who we are
      socket.emit('register_user', {
        'userId': _myEmail.isNotEmpty ? _myEmail : _myName,
        'displayName': _myName,
      });
    });

    // ── Incoming messages (including our own, broadcast by server) ──
    socket.on('receive_message', (data) {
      if (!mounted) return;
      final msg = _ChatMessage(
        id: data['id']?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
        sender: data['sender']?.toString() ?? '',
        senderName: data['senderName']?.toString() ?? 'Unknown',
        text: data['text']?.toString() ?? '',
        timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
        isSystem: data['sender'] == '__system__',
      );
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });

    // ── Active user list updates ──
    socket.on('user_list', (data) {
      if (!mounted) return;
      final list = (data['users'] as List?)
              ?.map((u) => {
                    'userId': u['userId']?.toString() ?? '',
                    'displayName': u['displayName']?.toString() ?? '',
                  })
              .toList() ??
          [];
      setState(() {
        _activeCount = data['count'] ?? list.length;
        _activeUsers = list;
      });
    });

    // ── Typing indicators ──
    socket.on('user_typing', (data) {
      if (!mounted) return;
      setState(() => _typingUser = data['displayName']?.toString());
      // Auto-clear after 3s in case stop_typing is missed
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _typingUser = null);
      });
    });

    socket.on('user_stop_typing', (_) {
      if (mounted) setState(() => _typingUser = null);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Sending ─────────────────────────────────────────
  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    socket.emit('send_message', {
      'sender': _myEmail.isNotEmpty ? _myEmail : _myName,
      'senderName': _myName,
      'text': text,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });

    _msgController.clear();
    _emitStopTyping();
    _inputFocus.requestFocus();
  }

  void _onTextChanged(String value) {
    if (value.trim().isNotEmpty && !_iAmTyping) {
      _iAmTyping = true;
      socket.emit('typing', {
        'userId': _myEmail.isNotEmpty ? _myEmail : _myName,
        'displayName': _myName,
      });
    }
    if (value.trim().isEmpty && _iAmTyping) {
      _emitStopTyping();
    }
  }

  void _emitStopTyping() {
    _iAmTyping = false;
    socket.emit('stop_typing');
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    socket.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────
  bool _isMe(String sender) {
    if (sender == _myName) return true;
    if (_myEmail.isNotEmpty && sender == _myEmail) return true;
    return false;
  }

  Color get _accent =>
      widget.palette.colorBlind ? CreationPalette.cbBlue : const Color(0xFF7C3AED);

  // ── Build ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),
          if (_typingUser != null) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Header with name + active count ─────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Chat icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.forum_rounded, color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Logged in as $_myName',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Active users badge
          GestureDetector(
            onTap: _showActiveUsersSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_activeCount online',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActiveUsersSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Online Users ($_activeCount)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (_activeUsers.isEmpty)
              const Text('No one else is online yet.', style: TextStyle(color: Colors.grey))
            else
              ..._activeUsers.map((u) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _accent.withOpacity(0.15),
                          child: Text(
                            (u['displayName'] ?? '?')[0].toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          u['displayName'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        if (_isMe(u['userId'] ?? '')) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('you', style: TextStyle(fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No messages yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
          const SizedBox(height: 6),
          Text('Be the first to say hello!', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ── Message list ────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];

        if (msg.isSystem) return _buildSystemMessage(msg);

        final isMe = _isMe(msg.sender);

        // Show date separator if needed
        final showDate = index == 0 ||
            _messages[index - 1].timestamp.day != msg.timestamp.day;

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.timestamp),
            _buildBubble(msg, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg.text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg, bool isMe) {
    final time =
        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _avatar(msg.senderName),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name (only for others)
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      msg.senderName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accent),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _accent : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe) _avatar(_myName),
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: _accent.withOpacity(0.15),
      child: Text(
        letter,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _accent),
      ),
    );
  }

  // ── Typing indicator ────────────────────────────────
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        '$_typingUser is typing…',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      ),
    );
  }

  // ── Input bar ───────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                focusNode: _inputFocus,
                onChanged: _onTextChanged,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _accent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _sendMessage,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}