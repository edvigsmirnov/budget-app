import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Money as an exact decimal string.
///
/// Never a double, and never a REAL column: 0.1 + 0.2 must be 0.3. The cost is
/// that SQL cannot sum or order these columns meaningfully — every aggregation
/// happens in Dart over [Decimal]. Row counts here are small enough for that
/// (plan section 4, M1 exit: 10k rows under 200 ms).
class DecimalConverter extends TypeConverter<Decimal, String>
    with JsonTypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}

/// A calendar day as `YYYY-MM-DD`, sortable and comparable as text.
class CalendarDateConverter extends TypeConverter<CalendarDate, String>
    with JsonTypeConverter<CalendarDate, String> {
  const CalendarDateConverter();

  @override
  CalendarDate fromSql(String fromDb) => CalendarDate.parse(fromDb);

  @override
  String toSql(CalendarDate value) => value.toIso();
}
