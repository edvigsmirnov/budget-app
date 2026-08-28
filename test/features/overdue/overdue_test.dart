import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/payment_repository.dart';
import 'package:sielto/core/db/repositories/space_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/overdue/overdue.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// What the missed-payments chip counts.
void main() {
  late AppDatabase db;
  late SpaceRepository spaces;
  late PaymentRepository payments;
  late Space space;

  final CalendarDate today = d('2026-03-10');

  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );

  setUp(() async {
    db = inMemoryDatabase();
    spaces = SpaceRepository(db: db, clock: clock);
    payments = PaymentRepository(db: db, clock: clock, userId: 'tester');
    space = await spaces.create(
      title: 'Flow',
      spaceType: SpaceType.personal,
      budgetMode: BudgetMode.flow,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
  });

  tearDown(() => db.close());

  Future<Payment> expense(
    String title,
    String date,
    String amount, {
    bool isPaid = false,
  }) => payments.create(
    spaceId: space.id,
    title: title,
    amount: m(amount),
    dueDate: d(date),
    expenseType: ExpenseType.mandatory,
    isPaid: isPaid,
  );

  Future<OverdueSummary> summary() async =>
      summariseOverdue(await payments.inSpace(space.id), today);

  test('unpaid expenses before today are counted and totalled', () async {
    await expense('rent', '2026-03-01', '600');
    await expense('card', '2026-03-05', '150');

    final OverdueSummary s = await summary();
    expect(s.count, 2);
    expect(s.total, m('750'));
  });

  test('oldest first, whichever order they were written in', () async {
    await expense('card', '2026-03-05', '150');
    await expense('rent', '2026-03-01', '600');

    final OverdueSummary s = await summary();
    expect(s.payments.map((Payment p) => p.title).toList(), <String>[
      'rent',
      'card',
    ]);
  });

  test('what is paid, due today or still ahead is not missed', () async {
    await expense('settled', '2026-03-01', '600', isPaid: true);
    await expense('due today', '2026-03-10', '150');
    await expense('ahead', '2026-03-20', '200');

    expect((await summary()).isEmpty, isTrue);
  });

  test('marking one paid drops it and shrinks the total', () async {
    final Payment rent = await expense('rent', '2026-03-01', '600');
    await expense('card', '2026-03-05', '150');
    await payments.setPaid(rent.id, isPaid: true);

    final OverdueSummary s = await summary();
    expect(s.count, 1);
    expect(s.total, m('150'));
  });

  test('a deleted payment is not owed', () async {
    final Payment rent = await expense('rent', '2026-03-01', '600');
    await payments.softDelete(rent.id);

    expect((await summary()).isEmpty, isTrue);
  });
}
