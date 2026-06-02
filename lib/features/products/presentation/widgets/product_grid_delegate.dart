import 'package:flutter/widgets.dart';

/// Shared responsive grid configuration.
///
/// Uses a max-cross-axis-extent delegate so columns grow naturally: ~2 on
/// phones, 3+ on tablets, without hard-coding counts. The child aspect ratio
/// leaves room for the 1:1 image plus the title / rating / price rows.
const SliverGridDelegateWithMaxCrossAxisExtent kProductGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.62,
    );
