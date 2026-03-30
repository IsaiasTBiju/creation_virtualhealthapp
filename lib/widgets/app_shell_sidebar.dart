import 'package:flutter/material.dart';

/// Shared sidebar row style (Creation member, healthcare, admin).
class AppShellSidebar {
  static Widget navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? accentWhenSelected,
  }) {
    final accent = accentWhenSelected ?? const Color.fromARGB(255, 90, 102, 235);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget header({
    required String title,
    required Color brandColor,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: brandColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static BoxDecoration panelDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF1F3F7),
      border: const Border(
        right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(2, 0),
        ),
      ],
    );
  }
}
