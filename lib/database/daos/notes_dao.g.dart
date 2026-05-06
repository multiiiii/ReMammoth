// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_dao.dart';

// ignore_for_file: type=lint
mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $FriendsTable get friends => attachedDatabase.friends;
  $NotesTable get notes => attachedDatabase.notes;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db.attachedDatabase, _db.friends);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db.attachedDatabase, _db.notes);
}
