import 'dart:async';

import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders every token and primitive for visual comparison against the design
/// canvas, and switches theme and locale so both audits run from one screen.
/// Development surface only; dropped from release builds at M3.
///
/// Section labels and sample rows are fixtures, deliberately not localized.
/// Only real product copy goes through `tr()`.
class TokenGalleryPage extends ConsumerWidget {
  const TokenGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors c = context.sage;
    final ThemeMode mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sage tokens'),
        actions: <Widget>[
          TextButton(
            onPressed: () => unawaited(_cycleLocale(context)),
            child: Text(context.locale.toString()),
          ),
          TextButton.icon(
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
            icon: Icon(switch (mode) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
            }),
            label: Text(switch (mode) {
              ThemeMode.system => 'theme.system'.tr(),
              ThemeMode.light => 'theme.light'.tr(),
              ThemeMode.dark => 'theme.dark'.tr(),
            }),
          ),
          const SizedBox(width: SageSpace.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SageSpace.gutter,
          SageSpace.sm,
          SageSpace.gutter,
          SageSpace.xl * 2,
        ),
        children: <Widget>[
          const _SectionLabel('Grounds'),
          _Swatches(<_Token>[
            _Token('canvas', c.canvas, 'Outer canvas, sheet backdrop'),
            _Token('surface', c.surface, 'App background'),
            _Token('card', c.card, 'Cards, inputs, rows'),
            _Token(
              'cardRaised',
              c.cardRaised,
              'Dark elevation; equals card on light',
            ),
          ]),

          const _SectionLabel('Ink'),
          _Swatches(<_Token>[
            _Token('ink', c.ink, 'Primary text'),
            _Token('inkHeading', c.inkHeading, 'Section headings'),
            _Token('inkSecondary', c.inkSecondary, 'Secondary text'),
            _Token('inkLabel', c.inkLabel, 'Field labels'),
            _Token('hairline', c.hairline, 'Row dividers'),
            _Token('border', c.border, 'Input borders'),
          ]),

          const _SectionLabel('Accent'),
          _Swatches(<_Token>[
            _Token('accent', c.accent, 'Invariant across themes'),
            _Token(
              'accentStrong',
              c.accentStrong,
              'Positive figures, action text',
            ),
            _Token('accentFill', c.accentFill, 'Surface behind accent text'),
            _Token('accentOn', c.accentOn, 'Invariant: on a solid accent fill'),
            _Token('accentTint', c.accentTint, 'Selected card'),
            _Token('accentTintAlt', c.accentTintAlt, 'Icon chips'),
          ]),

          const _SectionLabel('Semantic'),
          _Swatches(<_Token>[
            _Token('danger', c.danger, 'Overspend, destructive'),
            _Token('dangerTint', c.dangerTint, 'Overdue section'),
            _Token('warning', c.warning, 'Warning text'),
            _Token('warningAccent', c.warningAccent, 'Invariant: orange dot'),
            _Token('warningTint', c.warningTint, 'Warning wash'),
            _Token('sand', c.sand, 'Uncertainty band'),
            _Token('sandTint', c.sandTint, 'Band fill'),
          ]),

          const _SectionLabel('Coverage indicator'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _Dot(_Coverage.covered),
                const SizedBox(height: SageSpace.md),
                const _Dot(_Coverage.exact),
                const SizedBox(height: SageSpace.md),
                const _Dot(_Coverage.short),
              ],
            ),
          ),

          const _SectionLabel('Plurals'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SageSpace.sm,
              children: <Widget>[
                // Russian needs one/few/many; English needs two forms. Both
                // resolve from the same key.
                for (final int n in <int>[1, 2, 5])
                  Text(
                    'balance.excludedFromWalker'.plural(
                      n,
                      args: <String>['$n'],
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),

          const _SectionLabel('Type ramp'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SageSpace.sm,
              children: <Widget>[
                Text(
                  '1 240,00',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  'Free money',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Rent', style: Theme.of(context).textTheme.titleSmall),
                Text(
                  'Groceries this week',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Paid 12 August',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'payment.fieldAmount'.tr(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),

          const _SectionLabel('Primitives'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SageSpace.md,
              children: <Widget>[
                FilledButton(onPressed: () {}, child: Text('payment.add'.tr())),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('common.cancel'.tr()),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'payment.fieldTitle'.tr(),
                    hintText: 'Rent',
                  ),
                ),
                Wrap(
                  spacing: SageSpace.sm,
                  children: <Widget>[
                    Chip(
                      label: Text('payment.mandatory'.tr()),
                      backgroundColor: c.accentTintAlt,
                    ),
                    Chip(
                      label: Text('payment.overdue'.tr()),
                      backgroundColor: c.dangerTint,
                    ),
                    Chip(
                      label: Text('payment.uncertain'.tr()),
                      backgroundColor: c.sandTint,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const _SectionLabel('Row rhythm'),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _Row(
                  label: 'Rent',
                  amount: '-1 200,00',
                  paid: true,
                  mandatory: true,
                ),
                _Row(
                  label: 'Internet',
                  amount: '-39,90',
                  paid: true,
                  mandatory: true,
                ),
                _Row(
                  label: 'Groceries',
                  amount: '-85,00',
                  paid: false,
                  mandatory: false,
                ),
                _Row(
                  label: 'Salary',
                  amount: '+2 400,00',
                  paid: false,
                  mandatory: false,
                  income: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Steps through the supported locales, pseudo included in debug.
Future<void> _cycleLocale(BuildContext context) {
  final List<Locale> locales = context.supportedLocales;
  final int next = (locales.indexOf(context.locale) + 1) % locales.length;
  return context.setLocale(locales[next]);
}

enum _Coverage { covered, exact, short }

class _Dot extends StatelessWidget {
  const _Dot(this.coverage);

  final _Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    final (Color color, String label) = switch (coverage) {
      _Coverage.covered => (c.accentStrong, 'coverage.covered'.tr()),
      _Coverage.exact => (c.warningAccent, 'coverage.exact'.tr()),
      _Coverage.short => (c.danger, 'coverage.short'.tr()),
    };
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: SageSpace.md),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.amount,
    required this.paid,
    required this.mandatory,
    this.income = false,
  });

  final String label;
  final String amount;
  final bool paid;
  final bool mandatory;
  final bool income;

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SageSpace.gutter,
        vertical: SageSpace.row,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: paid ? c.accentStrong : Colors.transparent,
              border: paid ? null : Border.all(color: c.border, width: 1.5),
            ),
            child: paid ? Icon(Icons.check, size: 12, color: c.accentOn) : null,
          ),
          const SizedBox(width: SageSpace.md),
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: mandatory ? c.accent : Colors.transparent,
              border: mandatory ? null : Border.all(color: c.accent, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: income ? c.accentStrong : c.ink,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Token {
  const _Token(this.name, this.color, this.use);

  final String name;
  final Color color;
  final String use;
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.tokens);

  final List<_Token> tokens;

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    return Wrap(
      spacing: SageSpace.md,
      runSpacing: SageSpace.md,
      children: <Widget>[
        for (final _Token t in tokens)
          SizedBox(
            width: 168,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.color,
                    borderRadius: BorderRadius.circular(SageRadius.chip),
                    border: Border.all(color: c.border),
                  ),
                ),
                const SizedBox(height: SageSpace.xs + 2),
                Text(t.name, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  _hex(t.color),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                Text(t.use, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }

  static String _hex(Color c) {
    final int a = (c.a * 255).round();
    final int r = (c.r * 255).round();
    final int g = (c.g * 255).round();
    final int b = (c.b * 255).round();
    String two(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    return a == 255
        ? '#${two(r)}${two(g)}${two(b)}'
        : '#${two(a)}${two(r)}${two(g)}${two(b)}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, SageSpace.xl, 0, SageSpace.md),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(SageSpace.gutter),
        child: child,
      ),
    );
  }
}
