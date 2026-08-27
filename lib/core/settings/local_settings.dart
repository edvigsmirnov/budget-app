import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Feed row height and how much detail a row carries (spec 4.5).
enum FeedDensity {
  /// Amount and title on one line.
  compact,
  standard,

  /// Adds category and status on a second line.
  spacious,
}

/// Settings that belong to this device rather than to a Space or to the synced
/// profile: theme, feed density, the local user id, and which Space was open
/// last. None of it is ever uploaded (plan section 5, rule 5).
///
/// Backed by shared_preferences rather than the encrypted database: none of it
/// is sensitive, and the theme has to be readable before the database opens.
class LocalSettings {
  LocalSettings._(this._prefs, this.userId);

  static const Uuid _uuid = Uuid();

  static const String _keyUserId = 'user_id';
  static const String _keyNickname = 'nickname';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyFeedDensity = 'feed_density';
  static const String _keyCurrencyCode = 'currency_code';
  static const String _keyCurrentSpaceId = 'current_space_id';

  final SharedPreferences _prefs;

  /// Generated at first install and never replaced by a server value
  /// (plan section 2, invariant 4). Recorded as the author of every edit.
  final String userId;

  /// Reads the store and mints the user id if this is the first launch.
  static Future<LocalSettings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keyUserId);
    if (id == null) {
      id = _uuid.v4();
      await prefs.setString(_keyUserId, id);
    }
    return LocalSettings._(prefs, id);
  }

  /// Local until the first cloud action, when it becomes the public nickname
  /// (spec 2.1). Null means the onboarding step was skipped.
  String? get nickname => _prefs.getString(_keyNickname);

  Future<void> setNickname(String? value) async {
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _prefs.remove(_keyNickname);
      return;
    }
    await _prefs.setString(_keyNickname, trimmed);
  }

  ThemeMode get themeMode =>
      _readEnum(_keyThemeMode, ThemeMode.values) ?? ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_keyThemeMode, mode.name);

  FeedDensity get feedDensity =>
      _readEnum(_keyFeedDensity, FeedDensity.values) ?? FeedDensity.standard;

  Future<void> setFeedDensity(FeedDensity density) =>
      _prefs.setString(_keyFeedDensity, density.name);

  /// The currency answered at onboarding, used as the default for every Space
  /// created afterwards (spec 2.1). Null before that answer exists, where the
  /// device locale decides instead.
  ///
  /// Device-local rather than a Space field: each Space stores its own frozen
  /// currency, and this is only the starting point offered for the next one.
  String? get currencyCode => _prefs.getString(_keyCurrencyCode);

  Future<void> setCurrencyCode(String code) =>
      _prefs.setString(_keyCurrencyCode, code);

  /// The Space to reopen at launch. Cleared when that Space is gone.
  String? get currentSpaceId => _prefs.getString(_keyCurrentSpaceId);

  Future<void> setCurrentSpaceId(String? id) async {
    if (id == null) {
      await _prefs.remove(_keyCurrentSpaceId);
      return;
    }
    await _prefs.setString(_keyCurrentSpaceId, id);
  }

  /// Enums are stored by name, not index: a reordered enum would otherwise
  /// reinterpret a stored value.
  T? _readEnum<T extends Enum>(String key, List<T> values) {
    final String? name = _prefs.getString(key);
    if (name == null) return null;
    for (final T value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
