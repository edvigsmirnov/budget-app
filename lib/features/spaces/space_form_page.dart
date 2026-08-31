import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/currencies.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/onboarding/onboarding_scaffold.dart';
import 'package:sielto/features/spaces/starter_categories.dart';

/// The modes a Space can be created in, in the order the spec presents them
/// (spec 3.1). The choice is permanent, so all three have to be real before
/// any of them is offered — which they now are.
const List<BudgetMode> offeredBudgetModes = <BudgetMode>[
  BudgetMode.incomeDriven,
  BudgetMode.flow,
  BudgetMode.budget,
];

/// Creating a Space (spec 3.1).
///
/// Two of the choices here are permanent in different ways: the budget mode
/// has no update path anywhere in the app, and the currency freezes as soon as
/// the Space holds its first record. Everything else is editable later, in the
/// Space settings.
class SpaceFormPage extends ConsumerStatefulWidget {
  const SpaceFormPage({
    this.isFirstSpace = false,
    this.step,
    this.stepCount,
    super.key,
  });

  /// The onboarding entry point drops the app bar and its Back button: there
  /// is nothing to go back to.
  final bool isFirstSpace;

  /// Set when this form is the last step of onboarding, so it carries the same
  /// progress bar as the steps before it. Null when reached from the Spaces
  /// list, where there is no flow to show progress through.
  final int? step;
  final int? stepCount;

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
    // The onboarding answer first, the device locale only as a fallback.
    final String currency =
        _currency ??
        ref.read(localSettingsProvider).currencyCode ??
        Currencies.forLocale(locale);

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
        <({String title, String? icon, String? color, ExpenseType type})>[
          for (final StarterCategory c in starterCategories())
            (title: c.title, icon: c.icon, color: c.color, type: c.expenseType),
        ],
      );
      // Flow and Budget each hold exactly one open period, created here so
      // every later read can assume it exists (spec 4.7).
      await repos.periods.ensureContinuous(
        spaceId: space.id,
        startDate: repos.spaces.clockFor(space).today(),
      );
      await ref.read(currentSpaceIdProvider.notifier).select(space.id);
      // All the way back to the shell, not one step. The form can be reached
      // from Settings, and returning there after making a Space leaves the
      // user two screens away from the thing they just created.
      if (mounted && !widget.isFirstSpace) {
        Navigator.of(context).popUntil((Route<void> r) => r.isFirst);
      }
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
    // The onboarding answer first, the device locale only as a fallback.
    final String currency =
        _currency ??
        ref.read(localSettingsProvider).currencyCode ??
        Currencies.forLocale(locale);

    final int? step = widget.step;
    final int? stepCount = widget.stepCount;

    // As the last onboarding step this shares that flow's frame: the same
    // progress bar, and the primary action pinned rather than scrolling.
    if (step != null && stepCount != null) {
      return Scaffold(
        backgroundColor: sage.surface,
        body: OnboardingScaffold(
          step: step,
          stepCount: stepCount,
          title: tr('space.firstTitle'),
          body: tr('space.firstBody'),
          primaryLabel: tr('space.create'),
          onPrimary: _canSave ? _create : null,
          // Currency was step 2; asking again here would read as a second,
          // different question.
          children: _fields(locale, currency, showCurrency: false),
        ),
      );
    }

    return Scaffold(
      backgroundColor: sage.surface,
      appBar: AppBar(title: Text(tr('space.createTitle'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SageSpace.formGutter),
          children: <Widget>[
            ..._fields(locale, currency, showCurrency: true),
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

  /// The form body, shared by the onboarding frame and the standalone screen.
  List<Widget> _fields(
    String locale,
    String currency, {
    required bool showCurrency,
  }) => <Widget>[
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
    // Budget mode is absent rather than offered and broken: the mode is fixed
    // for the life of a Space (spec 3.1), so a Space created in a mode that
    // does not compute yet could never be moved out of it.
    for (final BudgetMode mode in offeredBudgetModes) ...<Widget>[
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
    if (showCurrency) ...<Widget>[
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
    ],
    const SizedBox(height: SageSpace.lg),
    FieldLabel(tr('space.fieldStorage')),
    const _StorageChoice(),
  ];
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
