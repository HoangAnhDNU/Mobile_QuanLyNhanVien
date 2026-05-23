class Department {
  final String id;
  final String name;
  final String? managerId;
  final String? description;
  final String? createdAt;

  // Joined fields
  final String? managerName;
  final int? employeeCount;

  const Department({
    required this.id,
    required this.name,
    this.managerId,
    this.description,
    this.createdAt,
    this.managerName,
    this.employeeCount,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'manager_id': managerId,
      'description': description,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Department.fromDbMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] as String,
      name: map['name'] as String,
      managerId: map['manager_id'] as String?,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
      managerName: map['manager_name'] as String?,
      employeeCount: map['employee_count'] as int?,
    );
  }

  Department copyWith({
    String? id,
    String? name,
    String? managerId,
    String? description,
    String? createdAt,
    String? managerName,
    int? employeeCount,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      managerId: managerId ?? this.managerId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      managerName: managerName ?? this.managerName,
      employeeCount: employeeCount ?? this.employeeCount,
    );
  }
}
