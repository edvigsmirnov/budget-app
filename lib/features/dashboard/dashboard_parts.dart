import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// The dashboard blocks the three modes share (spec 4.4).
///
/// They take plain values rather than a mode's ledger type, which is what lets
/// Flow and Regular income render the same cards from different arithmetic.

/// The hero figure.
///
/// While everything is covered this is a sum. Once it is not, the useful
/// answer is a date — how far the money reaches — and the figure turns red.
class MainFigureCard extends StatelessWidget {
  const MainFigureCard({
    required this.label,
    required this.amount,
    required this.coverage,
    required this.money,
    required this.overspend,
    required this.lastCoveredDay,
    required this.dates,
    required this.today,
    this.footer,
    this.onTap,
    super.key,
  });

  final String label;

  /// Null when the money does not cover everything, or is unknown.
  final Decimal? amount;

  final Coverage? coverage;
  final MoneyFormat money;

  /// The final balance, shown as an overspend when it went negative.
  final Decimal overspend;

  final CalendarDate? lastCoveredDay;
  final DateLabels dates;
  final CalendarDate today;

  /// An extra block under the figure — Flow puts its balance snapshot here.
  final Widget? footer;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final bool short = amount == null;

    return SageCard(
      padding: const EdgeInsets.all(SageSpace.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                short && lastCoveredDay != null ? tr('dashboard.lasts') : label,
                style: text.labelSmall,
              ),
              if (coverage != null) ...<Widget>[
                const SizedBox(width: SageSpace.sm),
                CoverageDot(coverage!),
              ],
            ],
          ),
          const SizedBox(height: SageSpace.sm),
          Text(
            switch ((amount, lastCoveredDay)) {
              (final Decimal value, _) => money.format(value),
              (null, final CalendarDate day) => dates.dayMonth(
                day,
                reference: today,
              ),
              (null, null) => money.format(overspend),
            },
            style: text.displaySmall?.copyWith(
              color: short ? sage.danger : sage.ink,
            ),
          ),
          if (short && overspend < Decimal.zero) ...<Widget>[
            const SizedBox(height: SageSpace.xs),
            Text(
              tr(
                'dashboard.overspend',
                namedArgs: <String, String>{'amount': money.format(-overspend)},
              ),
              style: text.bodySmall?.copyWith(color: sage.danger),
            ),
          ],
          if (footer != null) ...<Widget>[
            const SizedBox(height: SageSpace.md),
            const Hairline(),
            const SizedBox(height: SageSpace.md),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Mandatory first, then everything: two answers from one walk (spec 4.4).
class CascadeCard extends StatelessWidget {
  const CascadeCard({
    required this.baseRemainder,
    required this.netFree,
    required this.baseCoverage,
    required this.netCoverage,
    required this.money,
    super.key,
  });

  final Decimal? baseRemainder;
  final Decimal? netFree;
  final Coverage baseCoverage;
  final Coverage netCoverage;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('dashboard.cascade'), style: text.titleSmall),
          const SizedBox(height: SageSpace.md),
          _CascadeRow(
            label: tr('dashboard.baseRemainder'),
            hint: tr('dashboard.baseRemainderHint'),
            value: baseRemainder == null
                ? tr('dashboard.notCovered')
                : money.format(baseRemainder!),
            coverage: baseCoverage,
          ),
          const SizedBox(height: SageSpace.md),
          _CascadeRow(
            label: tr('dashboard.netFree'),
            hint: tr('dashboard.netFreeHint'),
            value: netFree == null
                ? tr('dashboard.notCovered')
                : money.format(netFree!),
            coverage: netCoverage,
          ),
        ],
      ),
    );
  }
}

class _CascadeRow extends StatelessWidget {
  const _CascadeRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.coverage,
  });

  final String label;
  final String hint;
  final String value;
  final Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: text.bodyLarge),
              Text(hint, style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: SageSpace.md),
        Text(
          value,
          style: text.titleSmall?.copyWith(
            color: CoverageDot.colorOf(context, coverage),
          ),
        ),
      ],
    );
  }
}

/// Planned, paid, still to pay (spec 4.4).
class TotalsCard extends StatelessWidget {
  const TotalsCard({
    required this.planned,
    required this.paid,
    required this.remaining,
    required this.money,
    super.key,
  });

  final Decimal planned;
  final Decimal paid;
  final Decimal remaining;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) => SageCard(
    child: Row(
      children: <Widget>[
        Expanded(
          child: StatColumn(
            label: tr('dashboard.planned'),
            value: money.format(planned),
          ),
        ),
        Expanded(
          child: StatColumn(
            label: tr('dashboard.paid'),
            value: money.format(paid),
          ),
        ),
        Expanded(
          child: StatColumn(
            label: tr('dashboard.leftToPay'),
            value: money.format(remaining),
          ),
        ),
      ],
    ),
  );
}

/// "In 5 days — Salary: 2 400 €" (spec 4.4).
class NearestIncomeCard extends StatelessWidget {
  const NearestIncomeCard({
    required this.income,
    required this.today,
    required this.money,
    super.key,
  });

  final Income? income;
  final CalendarDate today;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Income? row = income;

    if (row == null) {
      return SageCard(
        child: Text(tr('dashboard.noUpcomingIncome'), style: text.bodyMedium),
      );
    }

    final int days = today.daysUntil(row.expectedDate);
    final Decimal? amount = row.amount;

    return SageCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.south_west, size: 18, color: context.sage.accentStrong),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  days == 0
                      ? tr('dashboard.incomeToday')
                      : plural('dashboard.incomeInDays', days),
                  style: text.labelSmall,
                ),
                const SizedBox(height: SageSpace.xs),
                Text(row.title, style: text.bodyLarge),
              ],
            ),
          ),
          Text(
            amount == null ? tr('income.amountUnknown') : money.format(amount),
            style: text.titleSmall?.copyWith(
              color: amount == null
                  ? context.sage.inkLabel
                  : context.sage.accentStrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Space's mode, as a quiet badge under the header (design §2).
///
/// It answers "why does this screen look like this" — the three modes compute
/// different things, and the badge is what names which one is running.
class ModeBadge extends StatelessWidget {
  const ModeBadge(this.mode, {super.key});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: sage.accentTintAlt,
          borderRadius: BorderRadius.circular(SageRadius.pill),
        ),
        child: Text(
          mode,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: sage.accentStrong),
        ),
      ),
    );
  }
}
