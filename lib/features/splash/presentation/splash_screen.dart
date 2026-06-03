import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/folio_brand_lockup.dart';
import '../../products/presentation/providers/products_provider.dart';
import '../../products/presentation/screens/product_list_screen.dart';

/// Branded launch screen. Kicks off the catalogue fetch, plays a short brand
/// intro animation, then fades into the listing.
///
/// It stays visible for at least [_minVisible] (so the animation reads) and at
/// most [_maxWait] (so a stalled network can't trap the user on the splash).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minVisible = Duration(milliseconds: 1600);
  static const Duration _maxWait = Duration(seconds: 4);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  final DateTime _start = DateTime.now();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    // Safety net: leave even if the fetch never resolves.
    Future.delayed(_maxWait, _leave);
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// Called once the catalogue load settles (data or error); leaves after the
  /// minimum on-screen time has elapsed.
  void _onLoadResolved() {
    final remaining = _minVisible - DateTime.now().difference(_start);
    if (remaining <= Duration.zero) {
      _leave();
    } else {
      Future.delayed(remaining, _leave);
    }
  }

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const ProductListScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Prefetch the catalogue so the listing is ready, and leave once it settles.
    ref.listen(productsProvider, (_, next) {
      if (!next.isLoading) _onLoadResolved();
    });
    ref.watch(productsProvider);

    final width = MediaQuery.sizeOf(context).width;
    final logoSize = (width * 0.2).clamp(74.0, 112.0);
    final titleSize = (width * 0.14).clamp(42.0, 66.0);

    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final rise = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: rise,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FolioBrandLockup(
                      logoSize: logoSize,
                      fontSize: titleSize,
                      gap: 0,
                      textYOffset: 6,
                      centered: true,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 58,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'An editorial catalogue.',
                      textAlign: TextAlign.center,
                      style: AppTypography.manrope(
                        fontSize: 14.5,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colors.accent,
                      ),
                    ),
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
