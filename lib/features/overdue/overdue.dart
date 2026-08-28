import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/payments/payment_form_page.dart';
import 'package:sielto/features/periods/freeze_ui.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// What is past due and still unpaid (spec 4.5).
///
/// Not scoped to a period: a payment missed two cycles ago is still missed,
/// and the whole point of the figure is that it does not scroll away.
@immutable
class OverdueSummary {
  const OverdueSummary({required this.payments, required this.total});

  /// Oldest first — the order the detail list reads in.
  final List<Payment> payments;

  final Decimal total;

  int get count => payments.length;

  bool get isEmpty => payments.isEmpty;
}

/// Due before today and still unpaid (spec 4.5). Incomes are left out: an
/// income that has not arrived is late, not missed — nothing is owed.
OverdueSummary summariseOverdue(List<Payment> payments, CalendarDate today) {
  final List<Payment> missed =
      payments
          .where((Payment p) => !p.isPaid && p.dueDate.isBefore(today))
          .toList()
        ..sort((Payment a, Payment b) => a.dueDate.compareTo(b.dueDate));

  return OverdueSummary(
    payments: missed,
    total: missed.fold(
      Decimal.zero,
      (Decimal sum, Payment p) => sum + p.amount,
    ),
  );
}

final Provider<OverdueSummary> overduePaymentsProvider =
    Provider<OverdueSummary>(
      (Ref ref) => summariseOverdue(
        ref.watch(spacePaymentsProvider).value ?? const <Payment>[],
        ref.watch(spaceClockProvider).today(),
      ),
    );

/// The wide chip that says how much is owed late, on the Dashboard and under
/// the Feed's figures. Draws nothing when there is nothing missed.
class OverdueChip extends ConsumerWidget {
  const OverdueChip({required this.money, this.margin, super.key});

  final MoneyFormat money;

  /// Applied only when the chip has something to say, so an empty one leaves
  /// no gap behind it.
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final OverdueSummary summary = ref.watch(overduePaymentsProvider);
    if (summary.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: () => showOverdueSheet(context, money: money),
        borderRadius: BorderRadius.circular(SageRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SageSpace.md,
            vertical: SageSpace.sm,
          ),
          decoration: BoxDecoration(
            color: sage.dangerTint,
            borderRadius: BorderRadius.circular(SageRadius.button),
            border: Border.all(color: sage.danger.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.warning_amber_rounded, size: 18, color: sage.danger),
              const SizedBox(width: SageSpace.sm),
              Expanded(
                child: Text(
                  plural('overdue.count', summary.count),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: sage.danger),
                ),
              ),
              Text(
                money.format(summary.total),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: sage.danger,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              const SizedBox(width: SageSpace.xs),
              Icon(Icons.chevron_right, size: 18, color: sage.danger),
            ],
          ),
        ),
      ),
    );
  }
}

/// The missed payments in date order, each with the circle that settles it.
///
/// Marking one paid drops it out of the list and off the total, which is the
/// whole interaction: the sheet empties as the debt is cleared.
Future<void> showOverdueSheet(
  BuildContext context, {
  required MoneyFormat money,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext sheetContext) =>
      _OverdueSheet(money: money, host: context),
);

class _OverdueSheet extends ConsumerWidget {
  const _OverdueSheet({required this.money, required this.host});

  final MoneyFormat money;

  /// The screen that opened the sheet. Editing a payment pushes a route, which
  /// must outlive the sheet closing under it.
  final BuildContext host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final OverdueSummary summary = ref.watch(overduePaymentsProvider);
    final DateLabels dates = DateLabels(context.locale.toString());
    final CalendarDate today = ref.watch(spaceClockProvider).today();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SageSpace.gutter,
                SageSpace.lg,
                SageSpace.gutter,
                SageSpace.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(tr('overdue.title'), style: text.titleMedium),
                  ),
                  Text(
                    money.format(summary.total),
                    style: text.titleMedium?.copyWith(color: sage.danger),
                  ),
                ],
              ),
            ),
            const Hairline(),
            if (summary.isEmpty)
              Padding(
                padding: const EdgeInsets.all(SageSpace.xl),
                child: Center(
                  child: Text(tr('overdue.allSettled'), style: text.bodyMedium),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: SageSpace.md),
                  itemCount: summary.payments.length,
                  itemBuilder: (BuildContext context, int index) => _OverdueRow(
                    payment: summary.payments[index],
                    money: money,
                    dates: dates,
                    today: today,
                    onEdit: () {
                      Navigator.of(context).pop();
                      openPaymentForm(
                        host,
                        paymentId: summary.payments[index].id,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverdueRow extends ConsumerWidget {
  const _OverdueRow({
    required this.payment,
    required this.money,
    required this.dates,
    required this.today,
    required this.onEdit,
  });

  final Payment payment;
  final MoneyFormat money;
  final DateLabels dates;
  final CalendarDate today;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SageSpace.gutter,
          vertical: SageSpace.sm,
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: sage.accentStrong,
              tooltip: tr('payment.togglePaid'),
              onPressed: () => guardFreeze(
                context,
                () => ref
                    .read(repositoriesProvider)
                    .payments
                    .setPaid(payment.id, isPaid: true),
              ),
            ),
            const SizedBox(width: SageSpace.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    payment.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge,
                  ),
                  Text(
                    dates.dayMonth(payment.dueDate, reference: today),
                    style: text.bodySmall?.copyWith(color: sage.danger),
                  ),
                ],
              ),
            ),
            Text(
              money.format(payment.amount),
              style: text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
