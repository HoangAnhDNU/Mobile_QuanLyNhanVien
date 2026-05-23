import '../../../../core/database/daos/user_dao.dart';
import '../models/user_model.dart';

class AuthRepository {
  final UserDao _userDao = UserDao();

  User? _currentUser;
  bool _isLoggedIn = false;

  Future<User?> login(String username, String password) async {
    final user = await _userDao.authenticate(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
  }

  Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<String?> getCurrentUserRole() async {
    return _currentUser?.role;
  }
}
