class Salary {
  final String id;
  final String employeeId;
  final int month;
  final int year;
  final int workDays;
  final double baseSalary;
  final double allowance;
  final double deduction;
  final double netSalary;
  final String? createdAt;

  // Joined fields
  final String? employeeName;

  const Salary({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    this.workDays = 0,
    this.baseSalary = 0,
    this.allowance = 0,
    this.deduction = 0,
    this.netSalary = 0,
    this.createdAt,
    this.employeeName,
  });

  factory Salary.fromJson(Map<String, dynamic> json) => Salary.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'month': month,
      'year': year,
      'work_days': workDays,
      'base_salary': baseSalary,
      'allowance': allowance,
      'deduction': deduction,
      'net_salary': netSalary,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Salary.fromDbMap(Map<String, dynamic> map) {
    return Salary(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      workDays: (map['work_days'] as int?) ?? 0,
      baseSalary: (map['base_salary'] as num?)?.toDouble() ?? 0,
      allowance: (map['allowance'] as num?)?.toDouble() ?? 0,
      deduction: (map['deduction'] as num?)?.toDouble() ?? 0,
      netSalary: (map['net_salary'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as String?,
      employeeName: map['employee_name'] as String?,
    );
  }

  Salary copyWith({
    String? id,
    String? employeeId,
    int? month,
    int? year,
    int? workDays,
    double? baseSalary,
    double? allowance,
    double? deduction,
    double? netSalary,
    String? createdAt,
    String? employeeName,
  }) {
    return Salary(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      year: year ?? this.year,
      workDays: workDays ?? this.workDays,
      baseSalary: baseSalary ?? this.baseSalary,
      allowance: allowance ?? this.allowance,
      deduction: deduction ?? this.deduction,
      netSalary: netSalary ?? this.netSalary,
      createdAt: createdAt ?? this.createdAt,
      employeeName: employeeName ?? this.employeeName,
    );
  }
}
