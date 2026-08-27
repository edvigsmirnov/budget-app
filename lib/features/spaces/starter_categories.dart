import 'package:easy_localization/easy_localization.dart';

/// The category set written at Space creation (spec 7).
///
/// Titles are translated at the moment of creation and stored as plain text
/// from then on: a category is user data, and a later interface-language
/// change must not rewrite what the user recorded.
List<String> starterCategoryTitles() => <String>[
  tr('starterCategory.rent'),
  tr('starterCategory.loans'),
  tr('starterCategory.utilities'),
  tr('starterCategory.internet'),
  tr('starterCategory.flexible'),
];
