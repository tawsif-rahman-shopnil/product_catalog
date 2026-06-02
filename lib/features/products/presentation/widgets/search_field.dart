import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

/// Search input that filters the list locally on every keystroke. Shows a
/// clear (✕) affordance once there is text.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : colors.surfaceAlt;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: colors.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.manrope(
                fontSize: 15,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search products',
                hintStyle: AppTypography.manrope(
                  fontSize: 15,
                  color: colors.textTertiary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    color: colors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 12, color: colors.card),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
