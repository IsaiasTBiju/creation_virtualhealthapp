import 'package:flutter/material.dart';

/// Original purple brand colours when [colorBlind] is false; blue-forward ramp when true.
class CreationPalette {
  final bool colorBlind;
  const CreationPalette({required this.colorBlind});

  Color get sidebarBrandTitle =>
      colorBlind ? const Color(0xFF005A9C) : Colors.purple;

  Color get navSelectedBackground => colorBlind
      ? const Color(0xFF005A9C)
      : const Color.fromARGB(255, 90, 102, 235);

  List<Color> get healthScoreGradient => colorBlind
      ? const [
          Color(0xFF004F8C),
          Color(0xFF0077CC),
          Color(0xFF4A9FD4),
        ]
      : const [
          Color(0xFF6C2CF3),
          Color(0xFFA855F7),
          Color(0xFFC084FC),
        ];

  Color get healthScoreSubtitle =>
      colorBlind ? const Color(0xFFB8E0FF) : const Color(0xFFBBF7D0);

  Color get healthScoreTrophy =>
      colorBlind ? Colors.white : Colors.yellow;

  Color get summaryIconBackground =>
      colorBlind ? const Color(0xFFE3F2FD) : const Color(0xFFF3E8FF);

  Color get summaryIconForeground =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF6C2CF3);

  Color get workoutRowIcon =>
      colorBlind ? const Color(0xFF005A9C) : Colors.purple.shade400;

  Color get chatBubbleUser =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF6C2CF3);

  static const Color chatBubbleUserForeground = Colors.white;

  Color get settingsSectionIconBackground =>
      colorBlind ? const Color(0xFFE3F2FD) : const Color(0xFFF3E8FF);

  Color get settingsSectionIconForeground =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF7C3AED);

  Color get switchActiveThumb =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF7C3AED);

  Color get switchActiveTrackTranslucent =>
      switchActiveThumb.withValues(alpha: 0.45);

  Color get sliderActive =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF8B5CF6);

  Color get sliderThumb =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF7C3AED);

  /// Compact gradient (cards, weekly challenge strip).
  List<Color> get brandGradientShort => colorBlind
      ? const [Color(0xFF004F8C), Color(0xFF0077CC)]
      : const [Color(0xFF6C2CF3), Color(0xFFA855F7)];

  Color get brandGlowShadow =>
      summaryIconForeground.withValues(alpha: 0.35);

  /// Progress bars, badge accents (violet / blue).
  Color get accentViolet =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF8B5CF6);

  Color get accentDeepPurple =>
      colorBlind ? const Color(0xFF0077CC) : const Color(0xFF9333EA);

  Color get progressBrand => summaryIconForeground;

  Color get wellnessMoodSelectedFill =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF4F46E5);

  Color get socialPillIcon => workoutRowIcon;

  Color get socialLeaderboardRowHighlightBg => summaryIconBackground;

  Color get socialLeaderboardBorderHighlight => colorBlind
      ? const Color(0xFF5DB3E8).withValues(alpha: 0.5)
      : const Color(0xFFC084FC).withValues(alpha: 0.5);

  Color get socialLeaderboardRankHighlight =>
      colorBlind ? const Color(0xFF005A9C) : const Color(0xFF7C3AED);

  Color get socialLeaderboardNameHighlight =>
      colorBlind ? const Color(0xFF003D6B) : const Color(0xFF5B21B6);

  Color get socialAvatarBackground =>
      colorBlind ? const Color(0xFFB8DAF0) : const Color(0xFFE9D5FF);

  Color get socialAvatarLetter =>
      colorBlind ? const Color(0xFF003D6B) : const Color(0xFF6B21A8);
}
