import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sielto/core/settings/local_settings.dart';
import 'package:sielto/core/settings/settings_providers.dart';

/// The device-local preferences that a screen reads through a controller.
///
/// The controllers exist because a plain read of the store never rebuilds
/// anything: these pin that setting a value both notifies and survives a
/// restart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerWith(LocalSettings settings) async {
    final ProviderContainer container = ProviderContainer(
      // No explicit list type: flutter_riverpod does not export `Override`.
      overrides: [localSettingsProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('feed density', () {
    test('defaults to standard', () async {
      final ProviderContainer container = await containerWith(
        await LocalSettings.load(),
      );
      expect(container.read(feedDensityProvider), FeedDensity.standard);
    });

    test('setting it notifies readers', () async {
      final ProviderContainer container = await containerWith(
        await LocalSettings.load(),
      );
      await container
          .read(feedDensityProvider.notifier)
          .set(FeedDensity.compact);
      expect(container.read(feedDensityProvider), FeedDensity.compact);
    });

    test('the choice survives a restart', () async {
      final LocalSettings first = await LocalSettings.load();
      final ProviderContainer a = await containerWith(first);
      await a.read(feedDensityProvider.notifier).set(FeedDensity.spacious);

      // A second load off the same store is what the next launch does.
      final ProviderContainer b = await containerWith(
        await LocalSettings.load(),
      );
      expect(b.read(feedDensityProvider), FeedDensity.spacious);
    });

    test(
      'stored by name, so reordering the enum cannot reinterpret it',
      () async {
        final ProviderContainer container = await containerWith(
          await LocalSettings.load(),
        );
        await container
            .read(feedDensityProvider.notifier)
            .set(FeedDensity.spacious);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('feed_density'), 'spacious');
      },
    );
  });

  group('holiday settings', () {
    test(
      'consent starts unanswered, which is not the same as refused',
      () async {
        final ProviderContainer container = await containerWith(
          await LocalSettings.load(),
        );
        expect(container.read(holidayConsentProvider), isNull);

        await container
            .read(holidayConsentProvider.notifier)
            .set(allowed: false);
        expect(container.read(holidayConsentProvider), isFalse);
      },
    );

    test('the default country round-trips upper case', () async {
      final ProviderContainer container = await containerWith(
        await LocalSettings.load(),
      );
      await container.read(defaultCountryProvider.notifier).set('de');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('default_country_code'), 'DE');
    });
  });
}
