import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/notes_dao.dart';
import 'daos/friends_dao.dart';

part 'app_database.g.dart';

class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get birthday => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get friendId =>
      integer().nullable().references(Friends, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Friends, Notes], daos: [NotesDao, FriendsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
                'ALTER TABLE friends ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE notes ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0');
          }
        },
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'remammoth_db');
  }
}
