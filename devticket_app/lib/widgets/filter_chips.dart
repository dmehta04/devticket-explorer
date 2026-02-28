import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/providers.dart';

class TimeFilterChips extends ConsumerWidget {
  const TimeFilterChips({super.key});

  static const filters = [
    (label: '1h', minutes: 60),
    (label: '2h', minutes: 120),
    (label: '3h', minutes: 180),
    (label: '4h+', minutes: 300),
    (label: 'All', minutes: 600),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(timeFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((f) {
          final isSelected = selected == f.minutes;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChoiceChip(
              label: Text(
                f.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onSelected: (_) {
                ref.read(timeFilterProvider.notifier).state = f.minutes;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
