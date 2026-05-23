import '../in_memory_database.dart';
import '../../../features/auth/data/models/user_model.dart';

class UserDao {
  final _mem = InMemoryDatabase();

  Future<User?> authenticate(String username, String password) async {
    final u = _mem.users.where((u) =>
        u['username'] == username &&
        u['password_hash'] == password &&
        u['status'] == 'active').firstOrNull;
    if (u == null) return null;
    return User.fromDbMap(u);
  }

  Future<User?> getById(String id) async {
    final u = _mem.users.where((u) => u['id'] == id).firstOrNull;
    if (u == null) return null;
    return User.fromDbMap(u);
  }

  Future<User?> getByUsername(String username) async {
    final u = _mem.users.where((u) => u['username'] == username).firstOrNull;
    if (u == null) return null;
    return User.fromDbMap(u);
  }

  Future<void> insert(User user) async {
    _mem.users.add(user.toDbMap());
  }

  Future<void> updatePassword(String id, String newPasswordHash) async {
    final index = _mem.users.indexWhere((u) => u['id'] == id);
    if (index >= 0) {
      _mem.users[index]['password_hash'] = newPasswordHash;
    }
  }

  Future<void> delete(String id) async {
    _mem.users.removeWhere((u) => u['id'] == id);
  }
}
