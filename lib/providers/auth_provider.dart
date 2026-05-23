import 'package:flutter/foundation.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthUser {
  final String id;
  final String username;
  final String role;

  AuthUser({required this.id, required this.username, required this.role});

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  final List<Map<String, String>> _users = [
    {'id': 'user_001', 'username': 'admin', 'password': 'admin123', 'role': 'admin'},
    {'id': 'user_002', 'username': 'manager', 'password': 'manager123', 'role': 'manager'},
  ];

  Future<void> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final found = _users.where(
      (u) => u['username'] == username && u['password'] == password,
    ).firstOrNull;

    if (found != null) {
      _user = AuthUser(id: found['id']!, username: found['username']!, role: found['role']!);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.error;
      _errorMessage = 'Sai tài khoản hoặc mật khẩu';
    }
    notifyListeners();
  }

  void logout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}
