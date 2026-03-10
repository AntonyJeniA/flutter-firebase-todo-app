// lib/widgets/empty_state.dart
// Empty state illustration

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/todo_provider.dart';
import '../utils/app_theme.dart';

class EmptyState extends StatelessWidget {
  final FilterType filter;

  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    String emoji;
    String title;
    String subtitle;

    switch (filter) {
      case FilterType.completed:
        emoji = '🎯';
        title = 'No Completed Tasks';
        subtitle = 'Tasks you finish will appear here.\nGo crush your goals!';
        break;
      case FilterType.active:
        emoji = '🎉';
        title = 'All Caught Up!';
        subtitle = 'No active tasks. Add something\nnew to stay productive.';
        break;
      default:
        emoji = '📝';
        title = 'No Tasks Yet';
        subtitle =
            'Tap the + button below to add\nyour first task and get started!';
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2A4E)),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
