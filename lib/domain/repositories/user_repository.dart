import '../../models/user_record.dart';

abstract class UserRepository {
  Future<List<UserRecord>> getUsers();

  Future<UserRecord?> getUserById(String id);

  Future<void> createUser(UserRecord user);

  Future<void> updateUser(UserRecord user);

  Future<void> deleteUser(String id);
}
