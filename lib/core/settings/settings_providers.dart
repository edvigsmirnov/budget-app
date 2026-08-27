import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/settings/local_settings.dart';

/// Overridden at startup, once the store has been read. Every device-local
/// preference goes through here.
final Provider<LocalSettings> localSettingsProvider = Provider<LocalSettings>(
  (Ref ref) => throw StateError('localSettingsProvider was not overridden'),
);

/// The local user id. Stable for the life of the install.
final Provider<String> userIdProvider = Provider<String>(
  (Ref ref) => ref.watch(localSettingsProvider).userId,
);

/// Feed row height and detail level (spec 4.5). Device-local, like the theme:
/// two members of a shared Space choose independently.
class FeedDensityController extends Notifier<FeedDensity> {
  @override
  FeedDensity build() => ref.watch(localSettingsProvider).feedDensity;

  Future<void> set(FeedDensity density) async {
    await ref.read(localSettingsProvider).setFeedDensity(density);
    state = density;
  }
}

final NotifierProvider<FeedDensityController, FeedDensity> feedDensityProvider =
    NotifierProvider<FeedDensityController, FeedDensity>(
      FeedDensityController.new,
    );

/// The country whose public holidays apply where a Space has not set its own
/// (spec 5.1.1, priority level 2).
class DefaultCountryController extends Notifier<String?> {
  @override
  String? build() => ref.watch(localSettingsProvider).defaultCountryCode;

  Future<void> set(String? code) async {
    await ref.read(localSettingsProvider).setDefaultCountryCode(code);
    state = code;
  }
}

final NotifierProvider<DefaultCountryController, String?>
defaultCountryProvider = NotifierProvider<DefaultCountryController, String?>(
  DefaultCountryController.new,
);

/// Whether the holiday list may be downloaded (spec 5.1.1).
///
/// Null is a real state, not a missing value: the question has not been asked,
/// which is what the one-time prompt keys off.
class HolidayConsentController extends Notifier<bool?> {
  @override
  bool? build() => ref.watch(localSettingsProvider).holidayFetchAllowed;

  Future<void> set({required bool? allowed}) async {
    await ref
        .read(localSettingsProvider)
        .setHolidayFetchAllowed(allowed: allowed);
    state = allowed;
  }
}

final NotifierProvider<HolidayConsentController, bool?> holidayConsentProvider =
    NotifierProvider<HolidayConsentController, bool?>(
      HolidayConsentController.new,
    );

/// The master network switch (spec 1). While it is on, no feature reaches the
/// network whatever its own consent says.
class OfflineModeController extends Notifier<bool> {
  @override
  bool build() => ref.watch(localSettingsProvider).fullyOffline;

  Future<void> set({required bool value}) async {
    await ref.read(localSettingsProvider).setFullyOffline(value: value);
    state = value;
  }
}

final NotifierProvider<OfflineModeController, bool> offlineModeProvider =
    NotifierProvider<OfflineModeController, bool>(OfflineModeController.new);
