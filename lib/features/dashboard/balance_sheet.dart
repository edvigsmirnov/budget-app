import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/format/money_input.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';

/// "Set current balance" (spec 4.6).
///
/// The figure is a snapshot of real money, and the moment it was taken matters
/// as much as the number: expenses already paid on or before that day are left
/// out of the walk so they are not charged twice (plan G1).
Future<void> showBalanceSheet(
  BuildContext context,
  WidgetRef ref, {
  required Space space,
  required MoneyFormat money,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext sheetContext) =>
      _BalanceSheet(space: space, money: money),
);

class _BalanceSheet extends ConsumerStatefulWidget {
  const _BalanceSheet({required this.space, required this.money});

  final Space space;
  final MoneyFormat money;

  @override
  ConsumerState<_BalanceSheet> createState() => _BalanceSheetState();
}

class _BalanceSheetState extends ConsumerState<_BalanceSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.space.manualBalance?.toString() ?? '',
  );

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Decimal? get _parsed {
    final Decimal? value = parseMoney(_amount.text);
    if (value == null || value < Decimal.zero) return null;
    return value;
  }

  Future<void> _save() async {
    final Decimal? value = _parsed;
    if (value == null) return;
    await ref
        .read(repositoriesProvider)
        .spaces
        .setManualBalance(widget.space.id, value);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: SageSpace.formGutter,
        right: SageSpace.formGutter,
        top: SageSpace.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SageSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('balance.sheetTitle'), style: text.titleMedium),
          const SizedBox(height: SageSpace.sm),
          Text(tr('balance.sheetBody'), style: text.bodyMedium),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('balance.fieldAmount'),
            child: TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
              ],
              decoration: InputDecoration(suffixText: widget.money.symbol),
              onSubmitted: (String _) => _save(),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          FilledButton(
            onPressed: _parsed == null ? null : _save,
            child: Text(tr('common.save')),
          ),
        ],
      ),
    );
  }
}
