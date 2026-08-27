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
