import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/categories/category_colors.dart';

/// One of the categories a new Space starts with.
@immutable
class StarterCategory {
  const StarterCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.expenseType,
  });

  final String title;
  final String icon;
  final String color;
  final ExpenseType expenseType;
}

/// The category set written at Space creation (spec 7).
///
/// Titles are translated at the moment of creation and stored as plain text
/// from then on: a category is user data, and a later interface-language
/// change must not rewrite what the user recorded.
///
/// They arrive with an icon, a colour and a default type rather than as bare
/// names — a starter set exists to show what a filled-in category looks like,
/// and five identical grey rows teach nothing.
List<StarterCategory> starterCategories() => <StarterCategory>[
  StarterCategory(
    title: tr('starterCategory.rent'),
    icon: '🏠',
    color: categoryPalette[1],
    expenseType: ExpenseType.mandatory,
  ),
  StarterCategory(
    title: tr('starterCategory.loans'),
    icon: '💳',
    color: categoryPalette[5],
    expenseType: ExpenseType.mandatory,
  ),
  StarterCategory(
    title: tr('starterCategory.utilities'),
    icon: '💡',
    color: categoryPalette[4],
    expenseType: ExpenseType.mandatory,
  ),
  StarterCategory(
    title: tr('starterCategory.internet'),
    icon: '📱',
    color: categoryPalette[8],
    expenseType: ExpenseType.mandatory,
  ),
  StarterCategory(
    title: tr('starterCategory.flexible'),
    icon: '🛒',
    color: categoryPalette[0],
    expenseType: ExpenseType.variable,
  ),
];
