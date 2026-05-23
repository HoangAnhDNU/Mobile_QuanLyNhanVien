class User {
  final String id;
  final String username;
  final String? passwordHash;
  final String role;
  final String? employeeId;
  final String status;
  final String? createdAt;

  const User({
    required this.id,
    required this.username,
    this.passwordHash,
    required this.role,
    this.employeeId,
    this.status = 'active',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'employee_id': employeeId,
      'status': status,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory User.fromDbMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String?,
      role: map['role'] as String,
      employeeId: map['employee_id'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as String?,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isEmployee => role == 'employee';

  User copyWith({
    String? id,
    String? username,
    String? passwordHash,
    String? role,
    String? employeeId,
    String? status,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
