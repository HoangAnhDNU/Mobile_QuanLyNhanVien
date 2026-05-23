class Employee {
  final String id;
  final String employeeCode;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String department;
  final String position;
  final String phone;
  final String email;
  final String startDate;
  final double baseSalary;
  final String status;

  Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.department,
    required this.position,
    required this.phone,
    required this.email,
    required this.startDate,
    required this.baseSalary,
    this.status = 'Đang làm',
  });

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? department,
    String? position,
    String? phone,
    String? email,
    String? startDate,
    double? baseSalary,
    String? status,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      startDate: startDate ?? this.startDate,
      baseSalary: baseSalary ?? this.baseSalary,
      status: status ?? this.status,
    );
  }
}
