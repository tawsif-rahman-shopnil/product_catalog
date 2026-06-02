# Folio

**Folio** is a polished, editorial e-commerce catalogue built with Flutter on
top of the [Fake Store API](https://fakestoreapi.com/products). Browse products,
search
locally, view rich detail pages, and save favorites that persist across
restarts — in light or dark mode.

The UI implements a Claude Design handoff: a warm-neutral light theme / true
dark theme, the **Manrope** sans paired with the **Newsreader** serif for
screen titles and prices, glass app-bar and favorite buttons, and a responsive
product grid.

## Features

- **Product listing** — image, title, price, and rating in a responsive grid.
- **Product details** — Hero image, full title, description, price, category,
  and rating, with a sticky price + Add to Bag bar.
- **Local search** — filters the loaded catalogue by title (and category) on
  every keystroke; no per-keystroke network calls.
- **Category filters** — All / Men / Women / Jewelry / Tech / Favorites chips.
- **Favorites** — toggle from the card or detail page; persisted with
  `shared_preferences` and restored on launch (with an app-bar count badge).
- **Loading / error / empty states** — shimmer skeletons on first load, a
  friendly error message with **Retry**, and an empty state with a clear action.
- **Infinite pagination** — the grid reveals a page of items at a time and
  loads more (with a bottom spinner) as you scroll; resets to the top when the
  search or category changes.
- **Pull-to-refresh** plus an app-bar refresh button.
- **Dark mode** — toggle in the app bar; the choice is persisted.
- **Responsive** — a max-cross-axis-extent grid grows from 2 columns on phones
  to 3+ on tablets without hard-coded counts.

## Architecture

MVVM with a clean, feature-first layout. **Riverpod** is the state management
solution (no `setState` for app state) — its `AsyncValue` maps directly onto
the loading / error / data states.

```
lib/
├─ main.dart                     # bootstrap: init SharedPreferences, ProviderScope
├─ app.dart                      # MaterialApp + theming
├─ core/
│  ├─ constants/                 # API endpoints
│  ├─ error/                     # AppException (user-facing errors)
│  ├─ providers.dart             # DI: prefs, http, repositories
│  ├─ theme/                     # AppColors, typography, ThemeData, theme mode
│  └─ widgets/                   # Shimmer, PrimaryButton
└─ features/
   ├─ products/
   │  ├─ data/                   # models · remote data source (http) · repository
   │  └─ presentation/
   │     ├─ providers/           # products (AsyncNotifier) · search/category filter
   │     ├─ screens/             # list · detail
   │     └─ widgets/             # card, image, rating, price, chips, states…
   └─ favorites/
      ├─ data/                   # SharedPreferences repository
      └─ presentation/           # favorites notifier · favorite button
```

**Data flow:** `ProductRemoteDataSource` (http) → `ProductRepository` →
`productsProvider` (`AsyncNotifier`) → `filteredProductsProvider` (applies
category + search) → UI. Favorites live in a separate `Notifier<Set<int>>`
backed by `FavoritesRepository`.

## Tech & dependencies

Deliberately minimal:

| Package                | Purpose                                  |
| ---------------------- | ---------------------------------------- |
| `flutter_riverpod`     | State management (MVVM)                  |
| `http`                 | Fetching products                        |
| `shared_preferences`   | Favorites + theme persistence            |
| `cached_network_image` | Image caching, placeholder, error widget |
| `google_fonts`         | Manrope + Newsreader                      |

## Getting started

```bash
flutter pub get
flutter run            # pick a device, or: -d chrome / -d windows
```

## Tests

Unit tests cover model parsing, the repository's success/error paths (via a
mocked `http` client), favorites persistence, and the search/filter logic.
Widget tests cover the price, favorite button, and error/empty views.

```bash
flutter analyze
flutter test
```

## Continuous integration

`.github/workflows/ci.yml` runs on every push and pull request: it checks
formatting, runs `flutter analyze`, executes the test suite, and builds a
release web bundle.
