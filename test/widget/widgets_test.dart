import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product_catalog/core/theme/app_theme.dart';
import 'package:product_catalog/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:product_catalog/features/products/presentation/widgets/price_text.dart';
import 'package:product_catalog/features/products/presentation/widgets/state_views.dart';

/// Wraps [child] in the app theme so widgets can resolve [AppColors].
Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('PriceText renders dollars and cents', (tester) async {
    await tester.pumpWidget(_host(const PriceText(value: 109.95)));
    expect(find.textContaining(r'$'), findsOneWidget);
    expect(find.textContaining('109'), findsOneWidget);
    expect(find.textContaining('.95'), findsOneWidget);
  });

  testWidgets('FavoriteButton reflects state and fires onToggle', (
    tester,
  ) async {
    var toggled = false;
    await tester.pumpWidget(
      _host(FavoriteButton(isFavorite: false, onToggle: () => toggled = true)),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    // The glass blur layer sits over the icon, so skip the hit-test warning.
    await tester.tap(find.byType(FavoriteButton), warnIfMissed: false);
    await tester.pump();
    expect(toggled, isTrue);

    await tester.pumpWidget(
      _host(FavoriteButton(isFavorite: true, onToggle: () {})),
    );
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('ErrorView shows message and triggers retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _host(ErrorView(message: 'Boom', onRetry: () => retried = true)),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Boom'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, isTrue);
  });

  testWidgets('EmptyView surfaces the search query and Clear action', (
    tester,
  ) async {
    var cleared = false;
    await tester.pumpWidget(
      _host(EmptyView(query: 'banana', onClear: () => cleared = true)),
    );

    expect(find.text('No products found'), findsOneWidget);
    expect(find.textContaining('banana'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pump();
    expect(cleared, isTrue);
  });
}
