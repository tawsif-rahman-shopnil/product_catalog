import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Glass circular heart toggle. Outline heart → filled red, with a spring
/// scale-pop when a product is added to favorites.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 36,
    this.glass = true,
  });

  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final bool glass;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    lowerBound: 1.0,
    upperBound: 1.18,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isFavorite) {
      _controller.forward(from: 1.0).then((_) => _controller.reverse());
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = widget.isFavorite
        ? colors.favorite
        : colors.textSecondary;

    Widget button = Semantics(
      button: true,
      label: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: Material(
        color: widget.glass ? colors.glass : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              size: widget.size * 0.5,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    if (widget.glass) {
      button = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: button,
          ),
        ),
      );
    }

    return ScaleTransition(scale: _controller, child: button);
  }
}
