import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/sort_order.dart';

part 'friends_dao.g.dart';

@DriftAccessor(tables: [Friends])
class FriendsDao extends DatabaseAccessor<AppDatabase> with _$FriendsDaoMixin {
  FriendsDao(super.db);

  Stream<List<Friend>> watchFriends({SortOrder sort = SortOrder.newest}) {
    final query = select(friends)
      ..orderBy([
        (f) => OrderingTerm.desc(f.isPinned),
        (f) {
          switch (sort) {
            case SortOrder.newest:
              return OrderingTerm.desc(f.createdAt);
            case SortOrder.oldest:
              return OrderingTerm.asc(f.createdAt);
            case SortOrder.alphabetical:
              return OrderingTerm.asc(f.name);
            case SortOrder.lastEdited:
              return OrderingTerm.desc(f.createdAt);
          }
        },
      ]);
    return query.watch();
  }

  Future<int> insertFriend({required String name, DateTime? birthday}) {
    return into(friends).insert(
      FriendsCompanion(
        name: Value(name),
        birthday: Value(birthday),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> updateFriend(Friend friend) {
    return update(friends).replace(friend);
  }

  Future<int> deleteFriend(int id) {
    return (delete(friends)..where((f) => f.id.equals(id))).go();
  }

  Future<void> togglePin(Friend friend) {
    return update(friends).replace(
      friend.copyWith(isPinned: !friend.isPinned),
    );
  }
}
