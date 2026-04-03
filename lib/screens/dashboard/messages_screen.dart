import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../creation_palette.dart';
import '../../app_session.dart'; // To get your logged-in name

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late io.Socket socket;
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String myName = "Me"; // Default

  @override
  void initState() {
    super.initState();
    _loadMyName();
    _initSocket();
  }

  // Automatically get your name from the session
  Future<void> _loadMyName() async {
    final name = await AppSession.displayName();
    if (name != null && name.isNotEmpty) {
      setState(() {
        myName = name;
      });
    }
  }

  void _initSocket() {
    // Change this to your server IP if testing on a physical device
    socket = io.io('http://localhost:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': data['sender']?.toString() ?? 'Unknown',
            'text': data['text']?.toString() ?? '',
          });
        });
      }
    });
  }

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      final msgData = {
        'sender': myName,
        'text': _msgController.text.trim(),
      };
      socket.emit('send_message', msgData);
      setState(() {
        _messages.add(msgData);
      });
      _msgController.clear();
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBlind = CreationPalette.isColorBlind(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Community Chat", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // CLEANED TOP AREA: Just shows your identity status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: colorBlind ? CreationPalette.cbBlue.withOpacity(0.1) : Colors.purple.withOpacity(0.05),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colorBlind ? CreationPalette.cbBlue : Colors.purple,
                  child: const Icon(Icons.person, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text("Chatting as: $myName", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                bool isMe = m['sender'] == myName;

                return _buildChatBubble(m['sender']!, m['text']!, isMe, colorBlind);
              },
            ),
          ),
          
          _buildInputArea(colorBlind),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String sender, String text, bool isMe, bool cb) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // NAME TAG ON TOP
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              isMe ? "You" : sender,
              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _userIcon(sender, cb), // Show icon for others
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe 
                      ? (cb ? CreationPalette.cbBlue : Colors.purple) 
                      : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isMe) _userIcon("Me", cb), // Show icon for me
            ],
          ),
        ],
      ),
    );
  }

  Widget _userIcon(String name, bool cb) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: cb ? CreationPalette.cbBlue.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
      child: Text(
        name[0].toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cb ? CreationPalette.cbBlue : Colors.purple),
      ),
    );
  }

  Widget _buildInputArea(bool cb) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, color: cb ? CreationPalette.cbBlue : Colors.purple),
          ),
        ],
      ),
    );
  }
}