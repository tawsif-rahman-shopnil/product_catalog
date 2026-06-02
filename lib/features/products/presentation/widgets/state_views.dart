import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import 'product_card_skeleton.dart';
import 'product_grid_delegate.dart';

/// Grid of shimmering skeleton cards shown during the initial load.
class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      // Sized by its content because it lives inside a SliverToBoxAdapter
      // (an unbounded-height context); it must not try to scroll itself.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: kProductGridDelegate,
      itemCount: 6,
      itemBuilder: (context, _) => const ProductCardSkeleton(),
    );
  }
}

/// Centered icon + headline + supporting line, used by the error and empty
/// states.
class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.tone,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final Widget message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Scroll + min-height so the message centers when there's room but never
    // overflows when the viewport shrinks (e.g. the keyboard is open).
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 34, color: tone),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.newsreader(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: AppTypography.manrope(
                  fontSize: 14.5,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                child: message,
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error state with a friendly message and a Retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: Icons.cloud_off_rounded,
      tone: context.colors.favorite,
      title: 'Something went wrong',
      message: Text(message),
      action: PrimaryButton(
        label: 'Retry',
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}

/// Empty state shown when no products match the current search / filter.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.query, this.onClear});

  final String query;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _StateMessage(
      icon: Icons.search,
      tone: colors.accent,
      title: 'No products found',
      message: query.isEmpty
          ? const Text('Try searching with a different keyword.')
          : Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Nothing matched '),
                  TextSpan(
                    text: '"$query"',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '. Try a different keyword.'),
                ],
              ),
            ),
      action: (query.isNotEmpty && onClear != null)
          ? PrimaryButton(
              label: 'Clear search',
              variant: ButtonVariant.soft,
              onPressed: onClear!,
            )
          : null,
    );
  }
}
