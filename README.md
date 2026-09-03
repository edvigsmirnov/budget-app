# Sielto

An offline-first planner for mandatory payments and shared budgets.

It answers one question: **how much can I actually spend?** — by subtracting every
upcoming obligation from the money that has arrived, including the ones that only
land at the end of the month. It is not an expense tracker and it does not connect
to a bank. Every figure is entered by hand, which is what makes it work the same
for a salaried household, a freelancer with irregular income, and a group of
friends splitting a trip.

- **No telemetry, no ads, no analytics.** Nothing is collected.
- **No account.** No email, no phone number, no name — a device identifier is the
  whole of it.
- **Local first.** The on-device SQLite database is the source of truth, always.
  Cloud sync exists only for Spaces you explicitly opt in to share.
- **Encrypted at rest**, with a recovery path that survives losing the device.

Source-available, distributed outside the app stores.

## Status

Early development. Nothing is released yet.

## Platforms

Android, Windows and Linux. Apple platforms are out of scope for this development
cycle.

## Building

Requires the Flutter SDK on `stable`. Android builds additionally need JDK 17 and
the Android SDK; Windows needs the Visual Studio C++ build tools, including the
ATL component; Linux needs the GTK development headers and `libsecret-1-dev`.

```sh
flutter pub get
flutter run -d windows          # or: -d <your android device>

flutter build apk --release
flutter build windows --release
flutter build linux --release
```

On Windows, enable Developer Mode first — Flutter needs it to create the plugin
symlinks, and every build fails without it.

## License

Source-Available Non-Commercial License. See [LICENSE](LICENSE) for full terms.
