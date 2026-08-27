import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/format/money_format.dart';
import 'package:budget_app/core/settings/local_settings.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/features/categories/category_colors.dart';
import 'package:budget_app/features/feed/feed_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Row heights per density (spec 4.5). Compact drops to title and amount on
/// one line; spacious adds category and status underneath.
double rowHeightFor(FeedDensity density) => switch (density) {
  FeedDensity.compact => 44,
  FeedDensity.standard => 56,
  FeedDensity.spacious => 72,
};

/// One record in the Feed.
///
/// Every gesture on this row is one of four: tap to edit, the circle to toggle
/// paid, swipe right to delete, long-press for the quick-add menu. Reordering
/// uses the grip on the right.
class FeedRowTile extends StatelessWidget {
  const FeedRowTile({
    required this.record,
    required this.isCovered,
    required this.density,
    required this.money,
    required this.category,
    required this.onTap,
    required this.onTogglePaid,
    required this.onDelete,
    required this.onLongPress,
    this.dragHandle,
    super.key,
  });

  final FeedRecord record;
  final bool isCovered;
  final FeedDensity density;
  final MoneyFormat money;

  /// Null when the record has no category, or is an income (spec 7).
  final Category? category;

  final VoidCallback onTap;
  final VoidCallback onTogglePaid;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  /// The reorder grip, supplied by the list so it can attach its own listener.
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final Color amountColor = record.isIncome
        ? sage.accentStrong
        : (isCovered ? sage.ink : sage.danger);

    return Dismissible(
      key: ValueKey<String>('dismiss:${record.id}'),
      // Right for delete, left for the paid toggle — the same two actions the
      // circle and the row menu offer (spec 4.5).
      direction: DismissDirection.horizontal,
      background: const _SwipeAction(
        alignment: Alignment.centerLeft,
        icon: Icons.delete_outline,
        labelKey: 'common.delete',
        isDestructive: true,
      ),
      secondaryBackground: const _SwipeAction(
        alignment: Alignment.centerRight,
        icon: Icons.check_circle_outline,
        labelKey: 'payment.togglePaid',
        isDestructive: false,
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          onDelete();
        } else {
          onTogglePaid();
        }
        // Both act through the query rather than the dismiss animation, so an
        // undone delete brings the row straight back.
        return false;
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: rowHeightFor(density),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SageSpace.gutter),
            child: Row(
              children: <Widget>[
                _PaidCircle(record: record, onTap: onTogglePaid),
                const SizedBox(width: SageSpace.md),
                _TypeMarker(record: record, category: category),
                const SizedBox(width: SageSpace.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          decoration: record.isPaid
                              ? TextDecoration.lineThrough
                              : null,
                          color: record.isPaid ? sage.inkSecondary : sage.ink,
                        ),
                      ),
                      if (density == FeedDensity.spacious)
                        Text(
                          _subtitle(record, category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (record.notes != null && record.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: SageSpace.sm),
                    child: IconButton(
                      icon: const Icon(Icons.sticky_note_2_outlined, size: 16),
                      visualDensity: VisualDensity.compact,
                      tooltip: tr('payment.note'),
                      onPressed: () => _showNote(context, record.notes!),
                    ),
                  ),
                Text(
                  _amountLabel(record, money),
                  style: text.bodyLarge?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                if (dragHandle != null) ...<Widget>[
                  const SizedBox(width: SageSpace.sm),
                  dragHandle!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _amountLabel(FeedRecord r, MoneyFormat money) {
    if (r.amount == null) return tr('income.amountUnknown');
    return r.isIncome ? '+${money.format(r.amount!)}' : money.format(r.amount!);
  }

  String _subtitle(FeedRecord r, Category? category) {
    final List<String> parts = <String>[
      if (category != null) category.title,
      if (r.isIncome)
        r.isPaid ? tr('income.received') : tr('income.expected')
      else
        r.isPaid ? tr('payment.paid') : tr('payment.unpaid'),
    ];
    return parts.join(' · ');
  }

  void _showNote(BuildContext context, String note) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: context.sage.card,
        content: Text(note, style: Theme.of(context).textTheme.bodyLarge),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('common.close')),
          ),
        ],
      ),
    );
  }
}

/// The status circle left of the amount (spec 4.5). Filled green once paid.
class _PaidCircle extends StatelessWidget {
  const _PaidCircle({required this.record, required this.onTap});

  final FeedRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 26,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Solid accent, so the tick keeps its contrast on both grounds
              // (plan section 5, rule 2).
              color: record.isPaid ? sage.accent : Colors.transparent,
              border: Border.all(
                color: record.isPaid ? sage.accent : sage.border,
                width: 1.5,
              ),
            ),
            child: record.isPaid
                ? Icon(Icons.check, size: 13, color: sage.accentOn)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Solid bar for mandatory, hollow for variable, in the category colour
/// (spec 6.2). Incomes carry the accent.
class _TypeMarker extends StatelessWidget {
  const _TypeMarker({required this.record, required this.category});

  final FeedRecord record;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final Color color = parseCategoryColor(category?.color) ?? sage.accent;
    final bool solid = record.isIncome || record.isMandatory;
    return Container(
      width: 3,
      height: 22,
      decoration: BoxDecoration(
        color: solid ? color : Colors.transparent,
        border: solid ? null : Border.all(color: color),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// What shows behind a row while it is swiped.
class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.alignment,
    required this.icon,
    required this.labelKey,
    required this.isDestructive,
  });

  final Alignment alignment;
  final IconData icon;
  final String labelKey;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final Color tint = isDestructive ? sage.dangerTint : sage.accentTint;
    final Color ink = isDestructive ? sage.danger : sage.accentStrong;
    return Container(
      color: tint,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: SageSpace.lg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: ink),
          const SizedBox(width: SageSpace.sm),
          Text(
            tr(labelKey),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}
