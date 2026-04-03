import 'package:flutter/material.dart';

import '../../creation_palette.dart';

class ChatbotScreen extends StatefulWidget {
  final CreationPalette palette;

  const ChatbotScreen({super.key, required this.palette});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final input = TextEditingController();
  final messages = <_Msg>[
    _Msg(false, 'Hi! I am your Creation health companion. Ask about workouts, hydration, sleep, or goals.')
  ];
  bool useContext = true;
  String tone = 'Motivational';

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Health Companion', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('RAG-ready UI shell with context controls and citation placeholders.',
                style: TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: messages.length,
                            itemBuilder: (ctx, i) =>
                                _bubble(messages[i]),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: TextField(
                                controller: input,
                                onSubmitted: (_) => _send(),
                                decoration: const InputDecoration(
                                  hintText: 'Ask a health question...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(onPressed: _send, child: const Text('Send')),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Session Controls', style: TextStyle(fontWeight: FontWeight.w700)),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: useContext,
                          title: const Text('Use personal context'),
                          subtitle: const Text('Workouts, meals, wellness, meds'),
                          onChanged: (v) => setState(() => useContext = v),
                        ),
                        const Text('Tone'),
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
                        const Text('Safety', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text(
                          'This assistant provides wellness guidance only and does not give medical diagnosis.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const Divider(),
                        const Text('Retrieval Metadata', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Sources: 0 (until RAG backend connected)'),
                        const Text('Citation mode: off'),
                      ]),
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

  Widget _bubble(_Msg m) {
    final p = widget.palette;
    return Align(
      alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: m.user ? p.chatBubbleUser : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: m.user
                ? CreationPalette.chatBubbleUserForeground
                : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  void _send() {
    final t = input.text.trim();
    if (t.isEmpty) return;
    setState(() {
      messages.add(_Msg(true, t));
      messages.add(_Msg(false,
          'Demo response. Once your RAG service is connected, this response can include grounded citations.'));
      input.clear();
    });
  }
}

class _Msg {
  final bool user;
  final String text;
  _Msg(this.user, this.text);
}
