import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum ButtonVariant { primary, soft, ghost }

/// App button with the three variants from the design (primary / soft / ghost)
/// and a subtle press-scale. Height 44 (md) or 54 (lg), radius 14.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.large = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool large;
  final bool fullWidth;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = widget.large ? 54.0 : 44.0;

    late final Color background;
    late final Color foreground;
    Border? border;
    List<BoxShadow>? shadow;

    switch (widget.variant) {
      case ButtonVariant.primary:
        background = colors.accent;
        foreground = Colors.white;
        if (!isDark) {
          shadow = [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ];
        }
      case ButtonVariant.soft:
        background = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : colors.surfaceAlt;
        foreground = colors.textPrimary;
      case ButtonVariant.ghost:
        background = Colors.transparent;
        foreground = colors.accent;
        border = Border.all(color: colors.border);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: height,
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            border: border,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTypography.manrope(
                  fontSize: widget.large ? 16 : 14.5,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
