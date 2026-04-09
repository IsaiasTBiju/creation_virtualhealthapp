import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// clean avatar widget using layered containers instead of ugly CustomPaint
class UserAvatar extends StatefulWidget {
  final double size;
  const UserAvatar({super.key, this.size = 120});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String _hairStyle = 'Short';
  String _hairColor = 'Black';
  String _eyeColor = 'Brown';
  String _faceShape = 'Oval';
  String _skinTone = 'Light';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hairStyle = p.getString('avatar_hair_style') ?? 'Short';
      _hairColor = p.getString('avatar_hair_color') ?? 'Black';
      _eyeColor = p.getString('avatar_eye_color') ?? 'Brown';
      _faceShape = p.getString('avatar_face_shape') ?? 'Oval';
      _skinTone = p.getString('avatar_skin_tone') ?? 'Light';
    });
  }

  Color get _skin {
    const tones = {
      'Light': Color(0xFFFDE8C9),
      'Medium': Color(0xFFD4A574),
      'Tan': Color(0xFFC68642),
      'Dark': Color(0xFF8D5524),
      'Deep': Color(0xFF5C3317),
    };
    return tones[_skinTone] ?? const Color(0xFFFDE8C9);
  }

  Color get _hairCol {
    const map = {
      'Black': Color(0xFF1A1A2E), 'Brown': Color(0xFF5C4033),
      'Blonde': Color(0xFFE8C872), 'Red': Color(0xFFC0392B),
      'Auburn': Color(0xFF8B4513), 'Gray': Color(0xFF95A5A6),
      'White': Color(0xFFECF0F1), 'Blue': Color(0xFF3498DB),
      'Pink': Color(0xFFE91E93), 'Purple': Color(0xFF9B59B6),
    };
    return map[_hairColor] ?? const Color(0xFF1A1A2E);
  }

  Color get _eyeCol {
    const map = {
      'Brown': Color(0xFF5D4037), 'Blue': Color(0xFF2196F3),
      'Green': Color(0xFF4CAF50), 'Hazel': Color(0xFF8D6E63),
      'Gray': Color(0xFF78909C), 'Amber': Color(0xFFFF9800),
    };
    return map[_eyeColor] ?? const Color(0xFF5D4037);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background circle
          Container(
            width: s, height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [const Color(0xFFE8F4FD), const Color(0xFFD1E8FF)],
              ),
            ),
          ),
          // neck
          Positioned(
            bottom: s * 0.05,
            child: Container(
              width: s * 0.22, height: s * 0.15,
              decoration: BoxDecoration(
                color: _skin,
                borderRadius: BorderRadius.circular(s * 0.05),
              ),
            ),
          ),
          // body/shoulders hint
          Positioned(
            bottom: 0,
            child: Container(
              width: s * 0.55, height: s * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.2),
                  topRight: Radius.circular(s * 0.2),
                ),
              ),
            ),
          ),
          // face
          Positioned(
            top: s * 0.18,
            child: Container(
              width: s * 0.52,
              height: s * 0.58,
              decoration: BoxDecoration(
                color: _skin,
                borderRadius: _faceRadius(s),
              ),
            ),
          ),
          // ears
          Positioned(
            top: s * 0.38,
            left: s * 0.17,
            child: Container(
              width: s * 0.08, height: s * 0.12,
              decoration: BoxDecoration(color: _skin, borderRadius: BorderRadius.circular(s * 0.04)),
            ),
          ),
          Positioned(
            top: s * 0.38,
            right: s * 0.17,
            child: Container(
              width: s * 0.08, height: s * 0.12,
              decoration: BoxDecoration(color: _skin, borderRadius: BorderRadius.circular(s * 0.04)),
            ),
          ),
          // hair
          _buildHair(s),
          // eyes
          Positioned(
            top: s * 0.42,
            left: s * 0.32,
            child: _buildEye(s),
          ),
          Positioned(
            top: s * 0.42,
            right: s * 0.32,
            child: _buildEye(s),
          ),
          // eyebrows
          Positioned(
            top: s * 0.37,
            left: s * 0.31,
            child: Container(width: s * 0.12, height: s * 0.025,
                decoration: BoxDecoration(color: _hairCol.withOpacity(0.6), borderRadius: BorderRadius.circular(4))),
          ),
          Positioned(
            top: s * 0.37,
            right: s * 0.31,
            child: Container(width: s * 0.12, height: s * 0.025,
                decoration: BoxDecoration(color: _hairCol.withOpacity(0.6), borderRadius: BorderRadius.circular(4))),
          ),
          // nose
          Positioned(
            top: s * 0.50,
            child: Container(width: s * 0.04, height: s * 0.06,
                decoration: BoxDecoration(
                  color: _skin.withRed((_skin.red - 15).clamp(0, 255)),
                  borderRadius: BorderRadius.circular(s * 0.02),
                )),
          ),
          // mouth
          Positioned(
            top: s * 0.60,
            child: Container(
              width: s * 0.14, height: s * 0.05,
              decoration: BoxDecoration(
                color: const Color(0xFFE57373),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(s * 0.08),
                  bottomRight: Radius.circular(s * 0.08),
                  topLeft: Radius.circular(s * 0.02),
                  topRight: Radius.circular(s * 0.02),
                ),
              ),
            ),
          ),
          // cheek blush
          Positioned(
            top: s * 0.52,
            left: s * 0.27,
            child: Container(width: s * 0.08, height: s * 0.04,
                decoration: BoxDecoration(color: const Color(0xFFFFCDD2).withOpacity(0.5), shape: BoxShape.circle)),
          ),
          Positioned(
            top: s * 0.52,
            right: s * 0.27,
            child: Container(width: s * 0.08, height: s * 0.04,
                decoration: BoxDecoration(color: const Color(0xFFFFCDD2).withOpacity(0.5), shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }

  BorderRadius _faceRadius(double s) {
    switch (_faceShape) {
      case 'Round': return BorderRadius.circular(s * 0.3);
      case 'Square': return BorderRadius.circular(s * 0.08);
      case 'Heart': return BorderRadius.only(
          topLeft: Radius.circular(s * 0.28), topRight: Radius.circular(s * 0.28),
          bottomLeft: Radius.circular(s * 0.15), bottomRight: Radius.circular(s * 0.15));
      case 'Diamond': return BorderRadius.circular(s * 0.2);
      default: return BorderRadius.circular(s * 0.22);
    }
  }

  Widget _buildEye(double s) {
    return Container(
      width: s * 0.11, height: s * 0.09,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(s * 0.05),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)]),
      child: Center(
        child: Container(
          width: s * 0.06, height: s * 0.06,
          decoration: BoxDecoration(color: _eyeCol, shape: BoxShape.circle),
          child: Align(
            alignment: const Alignment(0.3, -0.3),
            child: Container(width: s * 0.02, height: s * 0.02,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }

  Widget _buildHair(double s) {
    switch (_hairStyle) {
      case 'Bald':
        return const SizedBox.shrink();
      case 'Long':
        return Positioned(
          top: s * 0.08,
          child: Container(
            width: s * 0.62, height: s * 0.55,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.3), topRight: Radius.circular(s * 0.3),
                  bottomLeft: Radius.circular(s * 0.05), bottomRight: Radius.circular(s * 0.05))),
          ),
        );
      case 'Curly':
        return Stack(
          children: List.generate(7, (i) {
            final angle = i * 0.9 - 1.4;
            return Positioned(
              top: s * 0.10 + (i % 2) * s * 0.04,
              left: s * 0.18 + i * s * 0.08,
              child: Container(width: s * 0.14, height: s * 0.14,
                  decoration: BoxDecoration(color: _hairCol, shape: BoxShape.circle)),
            );
          }),
        );
      case 'Afro':
        return Positioned(
          top: s * 0.02,
          child: Container(
            width: s * 0.72, height: s * 0.52,
            decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.circular(s * 0.35)),
          ),
        );
      case 'Mohawk':
        return Positioned(
          top: s * 0.02,
          child: Container(
            width: s * 0.16, height: s * 0.30,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.08), topRight: Radius.circular(s * 0.08))),
          ),
        );
      case 'Bob':
        return Positioned(
          top: s * 0.10,
          child: Container(
            width: s * 0.58, height: s * 0.42,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.28), topRight: Radius.circular(s * 0.28),
                  bottomLeft: Radius.circular(s * 0.15), bottomRight: Radius.circular(s * 0.15))),
          ),
        );
      case 'Ponytail':
        return Stack(children: [
          Positioned(top: s * 0.10, child: Container(width: s * 0.56, height: s * 0.22,
              decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.25), topRight: Radius.circular(s * 0.25))))),
          Positioned(top: s * 0.12, right: s * 0.14, child: Container(width: s * 0.10, height: s * 0.25,
              decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.circular(s * 0.05)))),
        ]);
      default: // Short, Buzz Cut, Wavy
        return Positioned(
          top: s * 0.10,
          child: Container(
            width: s * 0.56, height: s * 0.22,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.25), topRight: Radius.circular(s * 0.25),
                  bottomLeft: Radius.circular(s * 0.05), bottomRight: Radius.circular(s * 0.05))),
          ),
        );
    }
  }
}

// static preview version for signup (before prefs are saved)
class AvatarPreview extends StatelessWidget {
  final double size;
  final String hairStyle;
  final String hairColor;
  final String eyeColor;
  final String faceShape;
  final String skinTone;

  const AvatarPreview({
    super.key,
    this.size = 120,
    this.hairStyle = 'Short',
    this.hairColor = 'Black',
    this.eyeColor = 'Brown',
    this.faceShape = 'Oval',
    this.skinTone = 'Light',
  });

  Color get _skin {
    const tones = {
      'Light': Color(0xFFFDE8C9), 'Medium': Color(0xFFD4A574),
      'Tan': Color(0xFFC68642), 'Dark': Color(0xFF8D5524), 'Deep': Color(0xFF5C3317),
    };
    return tones[skinTone] ?? const Color(0xFFFDE8C9);
  }

  Color get _hairCol {
    const map = {
      'Black': Color(0xFF1A1A2E), 'Brown': Color(0xFF5C4033),
      'Blonde': Color(0xFFE8C872), 'Red': Color(0xFFC0392B),
      'Auburn': Color(0xFF8B4513), 'Gray': Color(0xFF95A5A6),
      'White': Color(0xFFECF0F1), 'Blue': Color(0xFF3498DB),
      'Pink': Color(0xFFE91E93), 'Purple': Color(0xFF9B59B6),
    };
    return map[hairColor] ?? const Color(0xFF1A1A2E);
  }

  Color get _eyeCol {
    const map = {
      'Brown': Color(0xFF5D4037), 'Blue': Color(0xFF2196F3),
      'Green': Color(0xFF4CAF50), 'Hazel': Color(0xFF8D6E63),
      'Gray': Color(0xFF78909C), 'Amber': Color(0xFFFF9800),
    };
    return map[eyeColor] ?? const Color(0xFF5D4037);
  }

  BorderRadius _faceRadius(double s) {
    switch (faceShape) {
      case 'Round': return BorderRadius.circular(s * 0.3);
      case 'Square': return BorderRadius.circular(s * 0.08);
      case 'Heart': return BorderRadius.only(
          topLeft: Radius.circular(s * 0.28), topRight: Radius.circular(s * 0.28),
          bottomLeft: Radius.circular(s * 0.15), bottomRight: Radius.circular(s * 0.15));
      case 'Diamond': return BorderRadius.circular(s * 0.2);
      default: return BorderRadius.circular(s * 0.22);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = size;
    return SizedBox(
      width: s, height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // bg
          Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [const Color(0xFFE8F4FD), const Color(0xFFD1E8FF)]))),
          // neck
          Positioned(bottom: s * 0.05, child: Container(width: s * 0.22, height: s * 0.15,
              decoration: BoxDecoration(color: _skin, borderRadius: BorderRadius.circular(s * 0.05)))),
          // body
          Positioned(bottom: 0, child: Container(width: s * 0.55, height: s * 0.18,
              decoration: BoxDecoration(color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.2), topRight: Radius.circular(s * 0.2))))),
          // face
          Positioned(top: s * 0.18, child: Container(width: s * 0.52, height: s * 0.58,
              decoration: BoxDecoration(color: _skin, borderRadius: _faceRadius(s)))),
          // ears
          Positioned(top: s * 0.38, left: s * 0.17, child: Container(width: s * 0.08, height: s * 0.12,
              decoration: BoxDecoration(color: _skin, borderRadius: BorderRadius.circular(s * 0.04)))),
          Positioned(top: s * 0.38, right: s * 0.17, child: Container(width: s * 0.08, height: s * 0.12,
              decoration: BoxDecoration(color: _skin, borderRadius: BorderRadius.circular(s * 0.04)))),
          // hair
          _buildHair(s),
          // eyes
          Positioned(top: s * 0.42, left: s * 0.32, child: _eye(s)),
          Positioned(top: s * 0.42, right: s * 0.32, child: _eye(s)),
          // eyebrows
          Positioned(top: s * 0.37, left: s * 0.31, child: Container(width: s * 0.12, height: s * 0.025,
              decoration: BoxDecoration(color: _hairCol.withOpacity(0.6), borderRadius: BorderRadius.circular(4)))),
          Positioned(top: s * 0.37, right: s * 0.31, child: Container(width: s * 0.12, height: s * 0.025,
              decoration: BoxDecoration(color: _hairCol.withOpacity(0.6), borderRadius: BorderRadius.circular(4)))),
          // nose
          Positioned(top: s * 0.50, child: Container(width: s * 0.04, height: s * 0.06,
              decoration: BoxDecoration(color: _skin.withRed((_skin.red - 15).clamp(0, 255)),
                  borderRadius: BorderRadius.circular(s * 0.02)))),
          // mouth
          Positioned(top: s * 0.60, child: Container(width: s * 0.14, height: s * 0.05,
              decoration: BoxDecoration(color: const Color(0xFFE57373),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(s * 0.08), bottomRight: Radius.circular(s * 0.08),
                      topLeft: Radius.circular(s * 0.02), topRight: Radius.circular(s * 0.02))))),
          // blush
          Positioned(top: s * 0.52, left: s * 0.27, child: Container(width: s * 0.08, height: s * 0.04,
              decoration: BoxDecoration(color: const Color(0xFFFFCDD2).withOpacity(0.5), shape: BoxShape.circle))),
          Positioned(top: s * 0.52, right: s * 0.27, child: Container(width: s * 0.08, height: s * 0.04,
              decoration: BoxDecoration(color: const Color(0xFFFFCDD2).withOpacity(0.5), shape: BoxShape.circle))),
        ],
      ),
    );
  }

  Widget _eye(double s) {
    return Container(
      width: s * 0.11, height: s * 0.09,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(s * 0.05),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)]),
      child: Center(child: Container(width: s * 0.06, height: s * 0.06,
          decoration: BoxDecoration(color: _eyeCol, shape: BoxShape.circle),
          child: Align(alignment: const Alignment(0.3, -0.3),
              child: Container(width: s * 0.02, height: s * 0.02,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))))),
    );
  }

  Widget _buildHair(double s) {
    switch (hairStyle) {
      case 'Bald':
        return const SizedBox.shrink();
      case 'Long':
        return Positioned(top: s * 0.08, child: Container(width: s * 0.62, height: s * 0.55,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.3), topRight: Radius.circular(s * 0.3),
                    bottomLeft: Radius.circular(s * 0.05), bottomRight: Radius.circular(s * 0.05)))));
      case 'Curly':
        return Positioned(top: s * 0.06, child: SizedBox(width: s * 0.7, height: s * 0.25,
            child: Stack(children: List.generate(7, (i) => Positioned(
                top: (i % 2) * s * 0.04, left: i * s * 0.08,
                child: Container(width: s * 0.14, height: s * 0.14,
                    decoration: BoxDecoration(color: _hairCol, shape: BoxShape.circle)))))));
      case 'Afro':
        return Positioned(top: s * 0.02, child: Container(width: s * 0.72, height: s * 0.52,
            decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.circular(s * 0.35))));
      case 'Mohawk':
        return Positioned(top: s * 0.02, child: Container(width: s * 0.16, height: s * 0.30,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.08), topRight: Radius.circular(s * 0.08)))));
      case 'Bob':
        return Positioned(top: s * 0.10, child: Container(width: s * 0.58, height: s * 0.42,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.28), topRight: Radius.circular(s * 0.28),
                    bottomLeft: Radius.circular(s * 0.15), bottomRight: Radius.circular(s * 0.15)))));
      case 'Ponytail':
        return Positioned(top: s * 0.08, child: SizedBox(width: s * 0.7, height: s * 0.4,
            child: Stack(children: [
              Positioned(left: s * 0.07, child: Container(width: s * 0.56, height: s * 0.22,
                  decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(s * 0.25), topRight: Radius.circular(s * 0.25))))),
              Positioned(right: 0, top: s * 0.04, child: Container(width: s * 0.10, height: s * 0.25,
                  decoration: BoxDecoration(color: _hairCol, borderRadius: BorderRadius.circular(s * 0.05)))),
            ])));
      case 'Wavy':
        return Positioned(top: s * 0.08, child: Container(width: s * 0.60, height: s * 0.35,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.28), topRight: Radius.circular(s * 0.28),
                    bottomLeft: Radius.circular(s * 0.12), bottomRight: Radius.circular(s * 0.12)))));
      case 'Buzz Cut':
        return Positioned(top: s * 0.12, child: Container(width: s * 0.54, height: s * 0.16,
            decoration: BoxDecoration(color: _hairCol.withOpacity(0.7),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.25), topRight: Radius.circular(s * 0.25)))));
      default: // Short
        return Positioned(top: s * 0.10, child: Container(width: s * 0.56, height: s * 0.22,
            decoration: BoxDecoration(color: _hairCol,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(s * 0.25), topRight: Radius.circular(s * 0.25),
                    bottomLeft: Radius.circular(s * 0.05), bottomRight: Radius.circular(s * 0.05)))));
    }
  }
}