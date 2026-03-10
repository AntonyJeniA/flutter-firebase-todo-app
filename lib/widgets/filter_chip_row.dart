// lib/widgets/filter_chip_row.dart
// Filter buttons: All, Active, Completed

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/todo_provider.dart';
import '../utils/app_theme.dart';

class FilterChipRow extends StatelessWidget {
  final TodoProvider provider;

  const FilterChipRow({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          _FilterChip(
            label: 'All (${provider.totalCount})',
            icon: Icons.format_list_bulleted_rounded,
            isSelected: provider.filter == FilterType.all,
            onTap: () => provider.setFilter(FilterType.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active (${provider.activeCount})',
            icon: Icons.radio_button_unchecked_rounded,
            isSelected: provider.filter == FilterType.active,
            onTap: () => provider.setFilter(FilterType.active),
            color: AppTheme.priorityMedium,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done (${provider.completedCount})',
            icon: Icons.check_circle_rounded,
            isSelected: provider.filter == FilterType.completed,
            onTap: () => provider.setFilter(FilterType.completed),
            color: AppTheme.completedColor,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(30) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFF2A2A4E),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.textHint,
                size: 14,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: isSelected ? color : AppTheme.textHint,
                    fontSize: 11.5,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
