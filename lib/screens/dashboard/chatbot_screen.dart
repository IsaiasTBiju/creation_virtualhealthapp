import 'package:flutter/material.dart';

import '../../creation_palette.dart';
import '../../api_service.dart';
import '../../app_session.dart';

class ChatbotScreen extends StatefulWidget {
  final CreationPalette palette;

  const ChatbotScreen({super.key, required this.palette});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final messages = <_Msg>[];
  bool loading = false;
  bool useContext = true;
  String tone = 'Motivational';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // pull past conversations from the backend
  Future<void> _loadHistory() async {
    final token = await AppSession.getToken();
    if (token == null) return;
    final history = await ApiService.chatbotHistory(token);
    if (!mounted) return;
    setState(() {
      for (final item in history) {
        messages.add(_Msg(true, item['user_message'] ?? ''));
        messages.add(_Msg(false, item['bot_response'] ?? ''));
      }
    });
    if (messages.isEmpty) {
      setState(() {
        messages.add(_Msg(false, 'Hi! I\'m your Creation health companion. Ask me about workouts, hydration, sleep, nutrition, or your goals.'));
      });
    }
    _scrollDown();
  }

  Future<void> _send() async {
    final text = input.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      messages.add(_Msg(true, text));
      loading = true;
      input.clear();
    });
    _scrollDown();

    final token = await AppSession.getToken();
    if (token == null) {
      setState(() {
        messages.add(_Msg(false, 'You need to be logged in for the AI companion to work.'));
        loading = false;
      });
      return;
    }

    final result = await ApiService.chatbot(token, text);
    if (!mounted) return;

    setState(() {
      if (result != null) {
        messages.add(_Msg(false, result['bot_response'] ?? 'Sorry, I couldn\'t process that.'));
      } else {
        messages.add(_Msg(false, 'Couldn\'t reach the server. Make sure the backend is running.'));
      }
      loading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.palette.chatBubbleUser;

    return Container(
      color: const Color(0xFFF8F9FB),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Health Companion',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Personalized health guidance powered by your data',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // chat area
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                        ],
                      ),
                      child: Column(children: [
                        Expanded(
                          child: ListView.builder(
                            controller: scroll,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length + (loading ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i == messages.length && loading) {
                                return _typingIndicator(accent);
                              }
                              return _bubble(messages[i], accent);
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: TextField(
                                controller: input,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  hintText: 'Ask a health question...',
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F4F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Material(
                              color: accent,
                              borderRadius: BorderRadius.circular(24),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: _send,
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // side panel
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Session Controls',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: useContext,
                            title: const Text('Use personal context', style: TextStyle(fontSize: 13)),
                            subtitle: const Text('Workouts, meals, wellness data', style: TextStyle(fontSize: 11)),
                            onChanged: (v) => setState(() => useContext = v),
                          ),
                          const SizedBox(height: 4),
                          const Text('Tone', style: TextStyle(fontSize: 13)),
                          DropdownButton<String>(
                            value: tone,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Motivational', child: Text('Motivational')),
                              DropdownMenuItem(value: 'Clinical', child: Text('Clinical')),
                              DropdownMenuItem(value: 'Friendly', child: Text('Friendly')),
                            ],
                            onChanged: (v) => setState(() => tone = v ?? tone),
                          ),
                          const Divider(),
                          const Text('Safety', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 6),
                          const Text(
                            'This assistant provides wellness guidance only and does not give medical diagnosis.',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          ),
                          const Divider(),
                          const Text('How it works', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 6),
                          const Text(
                            'Responses are personalized using your profile, activity history, and gamification data via a RAG-based pipeline.',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Msg m, Color accent) {
    return Align(
      alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: m.user ? accent : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(m.user ? 16 : 4),
            bottomRight: Radius.circular(m.user ? 4 : 16),
          ),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: m.user ? Colors.white : const Color(0xFF111827),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator(Color accent) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: accent)),
            const SizedBox(width: 10),
            const Text('Thinking...', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool user;
  final String text;
  _Msg(this.user, this.text);
}