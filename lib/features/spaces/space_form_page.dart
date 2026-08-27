import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/format/currencies.dart';
import 'package:budget_app/core/settings/settings_providers.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/time/space_clock.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:budget_app/features/spaces/starter_categories.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Creating a Space (spec 3.1).
///
/// Two of the choices here are permanent in different ways: the budget mode
/// has no update path anywhere in the app, and the currency freezes as soon as
/// the Space holds its first record. Everything else is editable later, in the
/// Space settings.
class SpaceFormPage extends ConsumerStatefulWidget {
  const SpaceFormPage({this.isFirstSpace = false, super.key});

  /// The onboarding entry point drops the app bar and its Back button: there
  /// is nothing to go back to.
  final bool isFirstSpace;

  @override
  ConsumerState<SpaceFormPage> createState() => _SpaceFormPageState();
}

class _SpaceFormPageState extends ConsumerState<SpaceFormPage> {
  final TextEditingController _title = TextEditingController();
  BudgetMode _mode = BudgetMode.flow;
  String? _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && !_saving;

  Future<void> _create() async {
    setState(() => _saving = true);
    final Repositories repos = ref.read(repositoriesProvider);
    final String locale = context.locale.toString();
    final String currency = _currency ?? Currencies.forLocale(locale);

    try {
      final Space space = await repos.spaces.create(
        title: _title.text,
        // Cosmetic only; the mode is what drives the engine.
        spaceType: SpaceType.personal,
        budgetMode: _mode,
        ownerId: ref.read(userIdProvider),
        timezone: await _deviceTimezone(),
        currencyCode: currency,
      );
      await repos.categories.createStarterSet(
        space.id,
        starterCategoryTitles(),
      );
      // Flow and Budget each hold exactly one open period, created here so
      // every later read can assume it exists (spec 4.7).
      await repos.periods.ensureContinuous(
        spaceId: space.id,
        startDate: repos.spaces.clockFor(space).today(),
      );
      await ref.read(currentSpaceIdProvider.notifier).select(space.id);
      if (mounted && !widget.isFirstSpace) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The Space timezone is seeded from the device and edited later in settings
  /// (spec 3.1). UTC is the fallback when the platform gives an unknown name.
  Future<String> _deviceTimezone() async {
    try {
      final String name = (await FlutterTimezone.getLocalTimezone()).identifier;
      return SpaceClock.isKnownTimezone(name) ? name : 'UTC';
    } on Exception {
      return 'UTC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final String locale = context.locale.toString();
    final String currency = _currency ?? Currencies.forLocale(locale);

    return Scaffold(
      backgroundColor: sage.surface,
      appBar: widget.isFirstSpace
          ? null
          : AppBar(title: Text(tr('space.createTitle'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SageSpace.formGutter),
          children: <Widget>[
            if (widget.isFirstSpace) ...<Widget>[
              Text(
                tr('space.firstTitle'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: SageSpace.sm),
              Text(
                tr('space.firstBody'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: SageSpace.xl),
            ],
            LabelledField(
              label: tr('space.fieldTitle'),
              child: TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: tr('space.titleHint')),
              ),
            ),
            const SizedBox(height: SageSpace.lg),
            FieldLabel(tr('space.fieldMode')),
            for (final BudgetMode mode in BudgetMode.values) ...<Widget>[
              _ModeCard(
                mode: mode,
                selected: _mode == mode,
                onTap: () => setState(() => _mode = mode),
              ),
              const SizedBox(height: SageSpace.sm),
            ],
            Text(
              tr('space.modeIsPermanent'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SageSpace.lg),
            LabelledField(
              label: tr('space.fieldCurrency'),
              child: DropdownButtonFormField<String>(
                initialValue: currency,
                items: <DropdownMenuItem<String>>[
                  for (final String code in Currencies.offered(currency))
                    DropdownMenuItem<String>(
                      value: code,
                      child: Text(Currencies.label(code, locale)),
                    ),
                ],
                onChanged: (String? code) =>
                    setState(() => _currency = code ?? currency),
              ),
            ),
            const SizedBox(height: SageSpace.xs),
            Text(
              tr('space.currencyFreezes'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SageSpace.lg),
            FieldLabel(tr('space.fieldStorage')),
            const _StorageChoice(),
            const SizedBox(height: SageSpace.xl),
            FilledButton(
              onPressed: _canSave ? _create : null,
              child: Text(tr('space.create')),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three modes, with the explanation and examples from spec 3.1.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final BudgetMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SageCard(
      selected: selected,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected ? context.sage.accentStrong : context.sage.inkLabel,
          ),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tr('mode.${mode.name}.name'), style: text.titleSmall),
                const SizedBox(height: SageSpace.xs),
                Text(tr('mode.${mode.name}.body'), style: text.bodyMedium),
                const SizedBox(height: SageSpace.xs),
                Text(tr('mode.${mode.name}.examples'), style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Local versus cloud (spec 3.1). Cloud storage arrives in M8, so the choice
/// is shown but only one side of it can be taken.
class _StorageChoice extends StatelessWidget {
  const _StorageChoice();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        SageCard(
          selected: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tr('storage.local.name'), style: text.titleSmall),
              const SizedBox(height: SageSpace.xs),
              Text(tr('storage.local.body'), style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: SageSpace.sm),
        Opacity(
          opacity: 0.5,
          child: SageCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tr('storage.cloud.name'), style: text.titleSmall),
                const SizedBox(height: SageSpace.xs),
                Text(tr('storage.cloud.notYet'), style: text.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
