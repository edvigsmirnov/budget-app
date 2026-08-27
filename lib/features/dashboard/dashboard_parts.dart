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

/// The hero figure (design section 2).
///
/// Centred on the page ground rather than inside a card: it is the answer the
/// screen exists to give, and a card around it makes it read as one item in a
/// list of equals.
///
/// While everything is covered this is a sum. Once it is not, the useful
/// answer is a date — how far the money reaches — and the figure turns red.
class MainFigure extends StatelessWidget {
  const MainFigure({
    required this.label,
    required this.amount,
    required this.coverage,
    required this.money,
    required this.overspend,
    required this.lastCoveredDay,
    required this.dates,
    required this.today,
    this.subtitle,
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

  /// The line under the figure that says what it rests on — Flow puts its
  /// average daily spend here, because the date only means something once you
  /// know the rate it was computed at (spec 4.6).
  final String? subtitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final bool short = amount == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SageSpace.md),
        child: Column(
          children: <Widget>[
            Text(
              short && lastCoveredDay != null ? tr('dashboard.lasts') : label,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: sage.inkLabel),
            ),
            const SizedBox(height: SageSpace.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    switch ((amount, lastCoveredDay)) {
                      (final Decimal value, _) => money.format(value),
                      (null, final CalendarDate day) => dates.dayMonth(
                        day,
                        reference: today,
                      ),
                      (null, null) => money.format(overspend),
                    },
                    textAlign: TextAlign.center,
                    style: text.displaySmall?.copyWith(
                      color: short ? sage.danger : sage.ink,
                    ),
                  ),
                ),
                // Beside the figure, not beside the label: the dot qualifies
                // the number it sits next to.
                if (coverage != null) ...<Widget>[
                  const SizedBox(width: SageSpace.sm),
                  CoverageDot(coverage!),
                ],
              ],
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: SageSpace.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: sage.inkLabel),
              ),
            ],
            // How far past the money the plan goes. The date says when it runs
            // out; this says by how much, which is the figure you need to know
            // what to move.
            if (short && overspend < Decimal.zero) ...<Widget>[
              const SizedBox(height: SageSpace.xs),
              Text(
                tr(
                  'dashboard.overspend',
                  namedArgs: <String, String>{
                    'amount': money.format(-overspend),
                  },
                ),
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: sage.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mandatory first, then everything: two answers from one walk (spec 4.4).
///
/// Only the base remainder appears here. The net figure is the hero above, and
/// printing it twice on one screen invites the reader to look for a difference
/// that is not there.
class CascadeCard extends StatefulWidget {
  const CascadeCard({
    required this.available,
    required this.baseRemainder,
    required this.baseCoverage,
    required this.money,
    super.key,
  });

  /// What the walk started from, so the bar has something to be a share of.
  final Decimal available;

  final Decimal? baseRemainder;
  final Coverage baseCoverage;
  final MoneyFormat money;

  @override
  State<CascadeCard> createState() => _CascadeCardState();
}

class _CascadeCardState extends State<CascadeCard> {
  /// Closed until asked. The explanation is three lines that stop being news
  /// after the first read, and the figure below is the point of the card.
  bool _explained = false;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final Decimal? remainder = widget.baseRemainder;

    return SageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(tr('dashboard.cascade'), style: text.titleSmall),
              ),
              _HelpToggle(
                open: _explained,
                onTap: () => setState(() => _explained = !_explained),
              ),
            ],
          ),
          if (_explained) ...<Widget>[
            const SizedBox(height: SageSpace.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SageSpace.md),
              decoration: BoxDecoration(
                color: sage.accentTint,
                borderRadius: BorderRadius.circular(SageRadius.button),
              ),
              child: Text(
                tr('dashboard.cascadeHint'),
                style: text.bodySmall?.copyWith(color: sage.inkSecondary),
              ),
            ),
          ],
          const SizedBox(height: SageSpace.md),
          StatRow(
            label: tr('dashboard.baseRemainder'),
            value: remainder == null
                ? tr('dashboard.notCovered')
                : widget.money.format(remainder),
            valueColor: CoverageDot.colorOf(context, widget.baseCoverage),
            emphasised: true,
          ),
          const SizedBox(height: SageSpace.sm),
          _RemainderBar(
            available: widget.available,
            remainder: remainder,
            coverage: widget.baseCoverage,
          ),
        ],
      ),
    );
  }
}

/// The "?" that opens the explanation.
class _HelpToggle extends StatelessWidget {
  const _HelpToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: open ? sage.accentTintAlt : Colors.transparent,
          border: Border.all(color: sage.border),
        ),
        child: Text(
          '?',
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: sage.inkLabel),
        ),
      ),
    );
  }
}

/// How much of the money survives the mandatory payments.
///
/// The share is what the base remainder means, so it is drawn rather than left
/// for the reader to divide two numbers in their head.
class _RemainderBar extends StatelessWidget {
  const _RemainderBar({
    required this.available,
    required this.remainder,
    required this.coverage,
  });

  final Decimal available;
  final Decimal? remainder;
  final Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    // Nothing survived, or there was nothing to start with: an empty bar is
    // the honest drawing of both.
    final double share = (remainder == null || available <= Decimal.zero)
        ? 0
        : (remainder!.toDouble() / available.toDouble()).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(SageRadius.pill),
      child: LinearProgressIndicator(
        value: share,
        minHeight: 6,
        backgroundColor: sage.accentTintAlt,
        valueColor: AlwaysStoppedAnimation<Color>(
          CoverageDot.colorOf(context, coverage),
        ),
      ),
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
    child: Column(
      children: <Widget>[
        StatRow(label: tr('dashboard.planned'), value: money.format(planned)),
        StatRow(label: tr('dashboard.paid'), value: money.format(paid)),
        StatRow(
          label: tr('dashboard.leftToPay'),
          value: money.format(remaining),
        ),
      ],
    ),
  );
}

/// "In 5 days — Salary: 2 400 €" (spec 4.4).
///
/// On the accent tint rather than the plain card ground: money arriving is the
/// one thing on this screen that is unambiguously good news, and the tint is
/// what separates it from the three cards of obligations above.
class NearestIncomeCard extends StatelessWidget {
  const NearestIncomeCard({
    required this.income,
    required this.today,
    required this.money,
    this.onTap,
    super.key,
  });

  final Income? income;
  final CalendarDate today;
  final MoneyFormat money;

  /// Opens the income this card names. The salary is the figure the whole
  /// cycle rests on, and until now the only way to it was the Feed.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
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
      color: sage.accentTint,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('dashboard.nearestIncome'), style: text.titleSmall),
          const SizedBox(height: SageSpace.xs),
          Text(
            days == 0
                ? tr('dashboard.incomeToday')
                : plural('dashboard.incomeInDays', days),
            style: text.bodySmall?.copyWith(color: sage.inkSecondary),
          ),
          const SizedBox(height: SageSpace.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Text(
                  row.title,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: SageSpace.md),
              Text(
                amount == null
                    ? tr('income.amountUnknown')
                    : '+${money.format(amount)}',
                style: text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amount == null ? sage.inkLabel : sage.accentStrong,
                ),
              ),
            ],
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
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SageSpace.md,
          vertical: SageSpace.xs,
        ),
        decoration: BoxDecoration(
          color: sage.accentTintAlt,
          borderRadius: BorderRadius.circular(SageRadius.pill),
        ),
        child: Text(
          mode,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: sage.accentStrong),
        ),
      ),
    );
  }
}
