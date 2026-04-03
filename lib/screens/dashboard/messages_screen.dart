import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../creation_palette.dart';

class ChatMessage {
  final String from;
  final String body;
  final DateTime at;
  ChatMessage(this.from, this.body, this.at);
}

class MessagesScreen extends StatefulWidget {
  final CreationPalette palette;

  const MessagesScreen({super.key, required this.palette});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final serverCtrl = TextEditingController(text: 'http://127.0.0.1:3001');
  final selfCtrl = TextEditingController(text: 'user-web');
  final peerCtrl = TextEditingController(text: 'user-android');
  final roomCtrl = TextEditingController(text: 'creation-demo-room');
  final textCtrl = TextEditingController();

  io.Socket? socket;
  bool connected = false;
  String status = 'Disconnected';
  final List<ChatMessage> messages = [];
  StreamSubscription? ticker;

  @override
  void dispose() {
    ticker?.cancel();
    socket?.dispose();
    serverCtrl.dispose();
    selfCtrl.dispose();
    peerCtrl.dispose();
    roomCtrl.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  void connectSocket() {
    socket?.dispose();
    final s = io.io(
      serverCtrl.text.trim(),
      io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );
    s.onConnect((_) {
      if (!mounted) return;
      setState(() {
        connected = true;
        status = 'Connected';
      });
      s.emit('join_room', {'room': roomCtrl.text.trim(), 'userId': selfCtrl.text.trim()});
    });
    s.onDisconnect((_) {
      if (!mounted) return;
      setState(() {
        connected = false;
        status = 'Disconnected';
      });
    });
    s.onConnectError((e) {
      if (!mounted) return;
      setState(() => status = 'Error: $e');
    });
    s.on('private_message', (data) {
      if (!mounted || data is! Map) return;
      final body = data['body']?.toString() ?? '';
      final from = data['from']?.toString() ?? 'peer';
      if (body.isEmpty) return;
      setState(() => messages.add(ChatMessage(from, body, DateTime.now())));
    });
    s.connect();
    socket = s;
    ticker?.cancel();
    ticker = Stream.periodic(const Duration(seconds: 3)).listen((_) {
      socket?.emit('presence_ping', {'userId': selfCtrl.text.trim()});
    });
  }

  void sendMsg() {
    final body = textCtrl.text.trim();
    if (body.isEmpty) return;
    socket?.emit('private_message', {
      'room': roomCtrl.text.trim(),
      'from': selfCtrl.text.trim(),
      'to': peerCtrl.text.trim(),
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Do not append locally: the server broadcasts to the room (including you),
    // so private_message already adds one row for the sender.
    setState(() => textCtrl.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Real-time Messages', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Socket one-to-one chat. Use same room/server on web and emulator.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          _connectionBox(),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: messages.length,
                    itemBuilder: (ctx, i) {
                      final m = messages[i];
                      final mine = m.from == selfCtrl.text.trim();
                      final p = widget.palette;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: mine ? p.chatBubbleUser : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m.body,
                            style: TextStyle(
                              color: mine
                                  ? CreationPalette.chatBubbleUserForeground
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: textCtrl,
                        onSubmitted: (_) => sendMsg(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: connected ? sendMsg : null, child: const Text('Send')),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _connectionBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: serverCtrl,
                decoration: const InputDecoration(labelText: 'Socket server URL'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: connectSocket, child: const Text('Connect')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: selfCtrl, decoration: const InputDecoration(labelText: 'Your ID'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: peerCtrl, decoration: const InputDecoration(labelText: 'Peer ID'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room'))),
          ]),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Status: $status', style: const TextStyle(color: Color(0xFF6B7280))),
          ),
        ]),
      );
}
