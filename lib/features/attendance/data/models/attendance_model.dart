class Attendance {
  final String id;
  final String employeeId;
  final String date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? note;
  final String? createdAt;

  // Joined fields
  final String? employeeName;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.note,
    this.createdAt,
    this.employeeName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'note': note,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Attendance.fromDbMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      date: map['date'] as String,
      status: map['status'] as String,
      checkInTime: map['check_in_time'] as String?,
      checkOutTime: map['check_out_time'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String?,
      employeeName: map['employee_name'] as String?,
    );
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? date,
    String? status,
    String? checkInTime,
    String? checkOutTime,
    String? note,
    String? createdAt,
    String? employeeName,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      employeeName: employeeName ?? this.employeeName,
    );
  }
}

class AttendanceSummary {
  final String employeeId;
  final String employeeName;
  final int totalWorkDays;
  final int presentDays;
  final int absentApproved;
  final int absentUnapproved;
  final int lateDays;

  const AttendanceSummary({
    required this.employeeId,
    required this.employeeName,
    this.totalWorkDays = 0,
    this.presentDays = 0,
    this.absentApproved = 0,
    this.absentUnapproved = 0,
    this.lateDays = 0,
  });

  factory AttendanceSummary.fromDbMap(Map<String, dynamic> map) {
    return AttendanceSummary(
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String? ?? '',
      totalWorkDays: (map['total_work_days'] as int?) ?? 0,
      presentDays: (map['present_days'] as int?) ?? 0,
      absentApproved: (map['absent_approved'] as int?) ?? 0,
      absentUnapproved: (map['absent_unapproved'] as int?) ?? 0,
      lateDays: (map['late_days'] as int?) ?? 0,
    );
  }
}
