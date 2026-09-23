import '../../domain/repositories/user_repository.dart';
import '../../models/user_record.dart';
import '../prototype_data_store.dart';

class MockUserRepository implements UserRepository {
  MockUserRepository([PrototypeDataStore? store])
      : _store = store ?? PrototypeDataStore();

  final PrototypeDataStore _store;

  @override
  Future<List<UserRecord>> getUsers() async {
    return List<UserRecord>.unmodifiable(_store.users);
  }

  @override
  Future<UserRecord?> getUserById(String id) async {
    for (final user in _store.users) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<void> createUser(UserRecord user) async {
    _store.users.add(user);
    _store.markChanged();
  }

  @override
  Future<void> updateUser(UserRecord user) async {
    final index = _store.users.indexWhere((entry) => entry.id == user.id);
    if (index == -1) return;
    _store.users[index] = user;
    _store.markChanged();
  }

  @override
  Future<void> deleteUser(String id) async {
    final index = _store.users.indexWhere((user) => user.id == id);
    if (index == -1) return;
    _store.users[index] = _store.users[index].copyWith(status: 'Inactive');
    _store.markChanged();
  }
}
