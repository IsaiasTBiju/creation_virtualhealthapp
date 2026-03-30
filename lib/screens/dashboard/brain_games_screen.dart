import 'dart:math';
import 'package:flutter/material.dart';

class BrainGamesScreen extends StatefulWidget {
  const BrainGamesScreen({super.key});

  @override
  State<BrainGamesScreen> createState() => _BrainGamesScreenState();
}

class _BrainGamesScreenState extends State<BrainGamesScreen> {
  static const _words = [
    'WELLNESS',
    'BALANCE',
    'MINDFUL',
    'HEALTH',
    'ENERGY',
    'CALM',
    'STRONG',
    'CREATE',
  ];

  late String _word;
  late Set<String> _guessed;
  late Set<String> _wrong;
  static const int _maxWrong = 6;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _word = _words[Random().nextInt(_words.length)];
    _guessed = {};
    _wrong = {};
  }

  bool get _won =>
      _word.split('').every((c) => _guessed.contains(c));

  bool get _lost => _wrong.length >= _maxWrong;

  void _guess(String letter) {
    final L = letter.toUpperCase();
    if (_won || _lost) return;
    if (_guessed.contains(L) || _wrong.contains(L)) return;

    setState(() {
      if (_word.contains(L)) {
        _guessed.add(L);
      } else {
        _wrong.add(L);
      }
    });
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
            _hangmanCard(),
            const SizedBox(height: 28),
            _keyboard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Brain Games",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Quick mental wellness break — guess the word.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _secondaryButton("New word", () {
          setState(_newGame);
        }),
      ],
    );
  }

  Widget _secondaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Widget _hangmanCard() {
    final status = _won
        ? "You got it!"
        : _lost
            ? "The word was $_word"
            : "Wrong guesses: ${_wrong.length} / $_maxWrong";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _won
                  ? const Color(0xFF16A34A)
                  : _lost
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          _hangmanFigure(),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: _word.split('').map((c) {
              final show = _guessed.contains(c) || _won || _lost;
              return Container(
                width: 36,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF111827), width: 2),
                  ),
                ),
                child: Text(
                  show ? c : " ",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFF111827),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _hangmanFigure() {
    final stage = _wrong.length.clamp(0, _maxWrong);
    return SizedBox(
      height: 140,
      child: CustomPaint(
        size: const Size(160, 140),
        painter: _HangmanPainter(stage: stage),
      ),
    );
  }

  Widget _keyboard() {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pick a letter",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: row.split('').map((ch) {
                  final L = ch;
                  final used =
                      _guessed.contains(L) || _wrong.contains(L);
                  final correct = _guessed.contains(L);
                  return _keyChip(L, used, correct);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _keyChip(String letter, bool used, bool correct) {
    final disabled = used || _won || _lost;
    return Material(
      color: disabled
          ? (correct
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFF3F4F6))
          : const Color(0xFFF8F9FB),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : () => _guess(letter),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: disabled
                  ? (correct ? const Color(0xFF166534) : const Color(0xFF9CA3AF))
                  : const Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int stage;

  _HangmanPainter({required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Gallows base
    canvas.drawLine(Offset(20, h - 10), Offset(w - 20, h - 10), paint);
    canvas.drawLine(Offset(40, h - 10), Offset(40, 30), paint);
    canvas.drawLine(Offset(40, 30), Offset(w * 0.55, 30), paint);
    canvas.drawLine(Offset(w * 0.55, 30), Offset(w * 0.55, 50), paint);

    if (stage >= 1) {
      canvas.drawCircle(Offset(w * 0.55, 68), 18, paint);
    }
    if (stage >= 2) {
      canvas.drawLine(Offset(w * 0.55, 86), Offset(w * 0.55, 115), paint);
    }
    if (stage >= 3) {
      canvas.drawLine(Offset(w * 0.55, 95), Offset(w * 0.42, 108), paint);
    }
    if (stage >= 4) {
      canvas.drawLine(Offset(w * 0.55, 95), Offset(w * 0.68, 108), paint);
    }
    if (stage >= 5) {
      canvas.drawLine(Offset(w * 0.55, 115), Offset(w * 0.45, 138), paint);
    }
    if (stage >= 6) {
      canvas.drawLine(Offset(w * 0.55, 115), Offset(w * 0.65, 138), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) =>
      oldDelegate.stage != stage;
}
