import 'package:drift/drift.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:uuid/uuid.dart';

/// Base for every repository over a syncable table.
///
/// Two rules are easy to forget at a call site and fatal when forgotten, so
/// they live here instead:
///   - reads exclude soft-deleted rows;
///   - writes stamp `client_edited_at` and mark the row pending.
///
/// Subclasses expose typed queries; they do not re-implement either rule.
abstract class SyncedRepository<T extends Table, D extends DataClass> {
  SyncedRepository({
    required this.db,
    required this.clock,
    required this.userId,
  });

  static const Uuid _uuid = Uuid();

  final AppDatabase db;
  final SpaceClock clock;

  /// Local user id, generated at first install and never replaced by a server
  /// value (plan section 2, invariant 4). Recorded as the author of each edit.
  final String userId;

  /// The table this repository owns.
  TableInfo<T, D> get table;

  /// A fresh v4 id. Two offline devices must never mint the same one, so this
  /// is random, never a sequence.
  static String newId() => _uuid.v4();

  /// The casts below are safe by construction: every table this class is used
  /// with mixes in `SyncColumns` and declares a text `id`, and the schema test
  /// asserts exactly that.
  GeneratedColumn<bool> get _isDeleted =>
      table.columnsByName['is_deleted']! as GeneratedColumn<bool>;

  GeneratedColumn<String> get _id =>
      table.columnsByName['id']! as GeneratedColumn<String>;

  GeneratedColumn<String> get _spaceId =>
      table.columnsByName['space_id']! as GeneratedColumn<String>;

  /// `is_deleted = false`, as a reusable predicate.
  Expression<bool> get notDeleted => _isDeleted.equals(false);

  /// Every live row.
  SimpleSelectStatement<T, D> selectAlive() =>
      db.select(table)..where((T _) => notDeleted);

  /// The live rows of one Space.
  SimpleSelectStatement<T, D> selectAliveInSpace(String spaceId) =>
      db.select(table)..where((T _) => notDeleted & _spaceId.equals(spaceId));

  /// The stamp every write carries. Uses the injected clock, so no repository
  /// reads the system clock directly.
  ({DateTime editedAt, String author}) stamp() =>
      (editedAt: clock.nowUtc(), author: userId);

  /// Soft delete. The row stays so the change can propagate; a hard delete
  /// would simply reappear from another device (spec 10.2).
  Future<int> softDelete(String id) => _setDeleted(id, deleted: true);

  /// Undo of [softDelete], for the 5-7 second snackbar (spec 7).
  Future<int> restore(String id) => _setDeleted(id, deleted: false);

  Future<int> _setDeleted(String id, {required bool deleted}) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(table)..where((T _) => _id.equals(id))).write(
      RawValuesInsertable<D>(<String, Expression<Object>>{
        'is_deleted': Constant<bool>(deleted),
        'sync_status': const Constant<String>('pending'),
        'client_edited_at': Variable<DateTime>(s.editedAt),
        'last_modified_by': Variable<String>(s.author),
      }),
    );
  }
}
