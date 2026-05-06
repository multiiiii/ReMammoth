import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/sort_order.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchNotes({
    int? friendId,
    SortOrder sort = SortOrder.newest,
  }) {
    final query = select(notes)
      ..where(
        (n) => friendId == null
            ? n.friendId.isNull()
            : n.friendId.equals(friendId!),
      )
      ..orderBy([
        (n) => OrderingTerm.desc(n.isPinned),
        (n) {
          switch (sort) {
            case SortOrder.newest:
              return OrderingTerm.desc(n.createdAt);
            case SortOrder.oldest:
              return OrderingTerm.asc(n.createdAt);
            case SortOrder.alphabetical:
              return OrderingTerm.asc(n.title);
          }
        },
      ]);
    return query.watch();
  }

  Future<int> insertNote({
    required String title,
    String? description,
    int? friendId,
    bool isPinned = false,
  }) {
    final now = DateTime.now();
    return into(notes).insert(
      NotesCompanion(
        title: Value(title),
        description: Value(description),
        createdAt: Value(now),
        updatedAt: Value(now),
        friendId: Value(friendId),
        isPinned: Value(isPinned),
      ),
    );
  }

  Future<bool> updateNote(Note note) {
    return update(notes).replace(note.copyWith(updatedAt: DateTime.now()));
  }

  Future<int> deleteNote(int id) {
    return (delete(notes)..where((n) => n.id.equals(id))).go();
  }

  Future<void> togglePin(Note note) {
    return update(notes).replace(
      note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()),
    );
  }
}
