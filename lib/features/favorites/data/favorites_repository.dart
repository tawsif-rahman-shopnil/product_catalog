import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of favorite product ids in [SharedPreferences].
///
/// Favorites survive app restarts: the set is hydrated on launch and
/// rewritten on every toggle.
class FavoritesRepository {
  FavoritesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'folio.favorites.v1';

  Set<int> load() {
    final stored = _prefs.getStringList(_key) ?? const [];
    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> save(Set<int> ids) {
    return _prefs.setStringList(
      _key,
      ids.map((id) => id.toString()).toList(growable: false),
    );
  }
}
