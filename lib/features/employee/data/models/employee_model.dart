class Employee {
  final String id;
  final String employeeCode;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? departmentId;
  final String? positionId;
  final String? phone;
  final String? email;
  final String? startDate;
  final String? contractType;
  final double baseSalary;
  final String status;
  final String? avatarUrl;
  final String? createdAt;
  final String? updatedAt;

  // Joined fields (not stored in employees table)
  final String? departmentName;
  final String? positionName;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.departmentId,
    this.positionId,
    this.phone,
    this.email,
    this.startDate,
    this.contractType,
    this.baseSalary = 0,
    this.status = 'active',
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.departmentName,
    this.positionName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'department_id': departmentId,
      'position_id': positionId,
      'phone': phone,
      'email': email,
      'start_date': startDate,
      'contract_type': contractType,
      'base_salary': baseSalary,
      'status': status,
      'avatar_url': avatarUrl,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Employee.fromDbMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      employeeCode: map['employee_code'] as String,
      fullName: map['full_name'] as String,
      dateOfBirth: map['date_of_birth'] as String?,
      gender: map['gender'] as String?,
      departmentId: map['department_id'] as String?,
      positionId: map['position_id'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      startDate: map['start_date'] as String?,
      contractType: map['contract_type'] as String?,
      baseSalary: (map['base_salary'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'active',
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      departmentName: map['department_name'] as String?,
      positionName: map['position_name'] as String?,
    );
  }

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? departmentId,
    String? positionId,
    String? phone,
    String? email,
    String? startDate,
    String? contractType,
    double? baseSalary,
    String? status,
    String? avatarUrl,
    String? createdAt,
    String? updatedAt,
    String? departmentName,
    String? positionName,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      startDate: startDate ?? this.startDate,
      contractType: contractType ?? this.contractType,
      baseSalary: baseSalary ?? this.baseSalary,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      departmentName: departmentName ?? this.departmentName,
      positionName: positionName ?? this.positionName,
    );
  }
}
