import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders every design token and primitive in one place.
///
/// This is the M0 exit criterion made checkable: put this page beside the Sage
/// canvas and the light column must match it, then flip to dark and confirm the
/// derived set still holds its contrast. It is a development surface, not a
/// shipped screen — the router drops it from release builds at M3.
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
          TextButton.icon(
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
            icon: Icon(switch (mode) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
            }),
            label: Text(switch (mode) {
              ThemeMode.system => 'System',
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
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
                Text('AMOUNT', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),

          const _SectionLabel('Primitives'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SageSpace.md,
              children: <Widget>[
                FilledButton(
                  onPressed: () {},
                  child: const Text('Add payment'),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'TITLE',
                    hintText: 'Rent',
                  ),
                ),
                Wrap(
                  spacing: SageSpace.sm,
                  children: <Widget>[
                    Chip(
                      label: const Text('Mandatory'),
                      backgroundColor: c.accentTintAlt,
                    ),
                    Chip(
                      label: const Text('Overdue'),
                      backgroundColor: c.dangerTint,
                    ),
                    Chip(
                      label: const Text('Uncertain'),
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

enum _Coverage { covered, exact, short }

class _Dot extends StatelessWidget {
  const _Dot(this.coverage);

  final _Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    final (Color color, String label) = switch (coverage) {
      _Coverage.covered => (c.accentStrong, 'Covered, with room to spare'),
      _Coverage.exact => (c.warningAccent, 'Covered exactly, nothing spare'),
      _Coverage.short => (c.danger, 'Not covered before the next income'),
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
