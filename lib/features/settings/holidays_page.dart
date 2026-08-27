import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/holidays/countries.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// Settings → Weekends and holidays (spec 5.1.2).
///
/// Two blocks, as the spec asks. The public holidays are read-only: they are a
/// fact about a country, and showing them is what makes it clear which days
/// are already accounted for. Below them are the days the user added, which
/// are theirs to edit.
class HolidaysPage extends ConsumerWidget {
  const HolidaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? country = ref.watch(defaultCountryProvider);
    final bool offline = ref.watch(offlineModeProvider);
    final bool? consent = ref.watch(holidayConsentProvider);
    final DateLabels dates = DateLabels(context.locale.toString());

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('holidays.title'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SageSpace.xl),
        children: <Widget>[
          _SectionLabel(tr('holidays.country')),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(_countryLabel(ref, country)),
            subtitle: Text(tr('holidays.countryHint')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickCountry(context, ref),
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.cloud_download_outlined),
            title: Text(tr('holidays.download')),
            subtitle: Text(
              offline ? tr('holidays.blockedByOffline') : tr('holidays.source'),
            ),
            value: !offline && (consent ?? false),
            // The master switch wins, so the row goes inert rather than
            // pretending the choice still matters (spec 1).
            onChanged: offline
                ? null
                : (bool value) => ref
                      .read(holidayConsentProvider.notifier)
                      .set(allowed: value),
          ),

          const SizedBox(height: SageSpace.md),
          _SectionLabel(tr('holidays.publicTitle')),
          _PublicHolidays(country: country, dates: dates),

          const SizedBox(height: SageSpace.md),
          _SectionLabel(tr('holidays.customTitle')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SageSpace.gutter),
            child: Text(
              tr('holidays.customWarning'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: SageSpace.sm),
          const _CustomDays(),
          Padding(
            padding: const EdgeInsets.all(SageSpace.gutter),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: Text(tr('holidays.addDay')),
              onPressed: () => markNonWorkingDay(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  String _countryLabel(WidgetRef ref, String? code) {
    if (code == null) return tr('holidays.noCountry');
    final List<HolidayCountry> all =
        ref.watch(holidayCountriesProvider).value ?? const <HolidayCountry>[];
    for (final HolidayCountry c in all) {
      if (c.code == code) return '${c.name} ($code)';
    }
    return code;
  }

  Future<void> _pickCountry(BuildContext context, WidgetRef ref) async {
    final String? previous = ref.read(defaultCountryProvider);
    final _CountryResult? picked = await showModalBottomSheet<_CountryResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext _) => const _CountryPicker(),
    );
    if (picked == null) return;

    await ref.read(defaultCountryProvider.notifier).set(picked.code);
    // Setting a country for the first time is what triggers the one-time
    // question about the download (spec 5.1.1).
    if (picked.code != null &&
        previous == null &&
        ref.read(holidayConsentProvider) == null &&
        context.mounted) {
      await askHolidayConsent(context, ref);
    }
  }
}

/// The one-time download question (spec 5.1.1).
///
/// Asked when a country is first chosen, and never again on its own: a refusal
/// is an answer, not a postponement. The setting stays reversible on this
/// screen.
Future<void> askHolidayConsent(BuildContext context, WidgetRef ref) async {
  final bool allowed = await confirmDialog(
    context,
    title: tr('holidays.consentTitle'),
    body: tr('holidays.consentBody'),
    confirmLabel: tr('holidays.consentAllow'),
  );
  await ref.read(holidayConsentProvider.notifier).set(allowed: allowed);
}

/// Adds a non-working day: a date, then an optional name (spec 5.1.2).
///
/// Shared by this screen and the Feed's add menu, so both write the same row
/// with the same warning about what it does and does not affect.
Future<void> markNonWorkingDay(
  BuildContext context,
  WidgetRef ref, {
  CalendarDate? initial,
}) async {
  final CalendarDate today = ref.read(spaceClockProvider).today();
  final CalendarDate start = initial ?? today;

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: start.toUtcMidnight(),
    firstDate: DateTime.utc(start.year - 5),
    lastDate: DateTime.utc(start.year + 10),
  );
  if (picked == null || !context.mounted) return;

  final String? title = await _askDayTitle(context);
  if (title == null) return;

  await ref
      .read(repositoriesProvider)
      .customDays
      .add(
        date: CalendarDate.fromDateTime(picked),
        title: title.isEmpty ? null : title,
        // Bound to the country in force, so a day marked for Germany does not
        // silently apply to a Space kept on another country's calendar.
        countryCode: ref.read(defaultCountryProvider),
      );
  ref.invalidate(periodRefreshProvider);
}

/// Empty string means "no name", which is allowed. Null means cancelled.
Future<String?> _askDayTitle(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: context.sage.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SageRadius.card),
        ),
        title: Text(
          tr('holidays.dayTitle'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: tr('holidays.dayTitleHint')),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(tr('common.save')),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

/// This year's public holidays for the default country. Read-only.
class _PublicHolidays extends ConsumerWidget {
  const _PublicHolidays({required this.country, required this.dates});

  final String? country;
  final DateLabels dates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (country == null) {
      return _Note(tr('holidays.noCountryBody'));
    }

    final int year = ref.watch(spaceClockProvider).today().year;
    // Watched so the list fills in as soon as a fetch lands.
    final AsyncValue<Object?> refresh = ref.watch(resolvedCalendarProvider);

    return FutureBuilder<List<CalendarDate>?>(
      future: ref.watch(repositoriesProvider).holidays.cached(country!, year),
      builder:
          (BuildContext context, AsyncSnapshot<List<CalendarDate>?> snapshot) {
            if (refresh.isLoading ||
                snapshot.connectionState != ConnectionState.done) {
              return const _Note('…');
            }
            final List<CalendarDate>? days = snapshot.data;
            if (days == null || days.isEmpty) {
              return _Note(tr('holidays.notLoaded'));
            }
            return Column(
              children: <Widget>[
                for (final CalendarDate day in days)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.event_busy_outlined,
                      size: 20,
                      color: context.sage.inkLabel,
                    ),
                    title: Text(dates.short(day)),
                    subtitle: Text(dates.weekday(day)),
                  ),
              ],
            );
          },
    );
  }
}

/// The days the user marked, with a delete on each.
class _CustomDays extends ConsumerWidget {
  const _CustomDays();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CustomNonWorkingDay> days =
        ref.watch(customNonWorkingDaysProvider).value ??
        const <CustomNonWorkingDay>[];
    if (days.isEmpty) return _Note(tr('holidays.noCustomDays'));

    final DateLabels dates = DateLabels(context.locale.toString());
    return Column(
      children: <Widget>[
        for (final CustomNonWorkingDay day in days)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.event_busy,
              size: 20,
              color: context.sage.accentStrong,
            ),
            title: Text(day.title ?? dates.short(day.date)),
            subtitle: Text(
              day.title == null
                  ? dates.weekday(day.date)
                  : '${dates.short(day.date)} · ${dates.weekday(day.date)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: tr('common.delete'),
              onPressed: () async {
                await ref.read(repositoriesProvider).customDays.remove(day.id);
                ref.invalidate(periodRefreshProvider);
              },
            ),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: SageSpace.gutter,
      vertical: SageSpace.sm,
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SageSpace.gutter,
      SageSpace.md,
      SageSpace.gutter,
      SageSpace.xs,
    ),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );
}

/// Null code is the "no country" row, which is a choice rather than a cancel.
@immutable
class _CountryResult {
  const _CountryResult(this.code);

  final String? code;
}

class _CountryPicker extends ConsumerStatefulWidget {
  const _CountryPicker();

  @override
  ConsumerState<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends ConsumerState<_CountryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<HolidayCountry> all =
        ref.watch(holidayCountriesProvider).value ?? const <HolidayCountry>[];
    final String query = _query.trim().toLowerCase();
    final List<HolidayCountry> shown = query.isEmpty
        ? all
        : all
              .where(
                (HolidayCountry c) =>
                    c.name.toLowerCase().contains(query) ||
                    c.code.toLowerCase().contains(query),
              )
              .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SageSpace.gutter,
          0,
          SageSpace.gutter,
          SageSpace.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('holidays.country'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SageSpace.md),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: tr('holidays.searchCountry'),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: SageSpace.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('holidays.noCountry')),
              subtitle: Text(tr('holidays.noCountryBody')),
              onTap: () =>
                  Navigator.of(context).pop(const _CountryResult(null)),
            ),
            const Hairline(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: shown.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(shown[index].name),
                  trailing: Text(
                    shown[index].code,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () =>
                      Navigator.of(context)
                          .pop(_CountryResult(shown[index].code)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
