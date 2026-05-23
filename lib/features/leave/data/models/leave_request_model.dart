class LeaveRequest {
  final String id;
  final String employeeId;
  final String startDate;
  final String endDate;
  final String? reason;
  final String status;
  final String? approvedBy;
  final String? createdAt;

  // Joined fields
  final String? employeeName;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status = 'pending',
    this.approvedBy,
    this.createdAt,
    this.employeeName,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory LeaveRequest.fromDbMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      reason: map['reason'] as String?,
      status: map['status'] as String? ?? 'pending',
      approvedBy: map['approved_by'] as String?,
      createdAt: map['created_at'] as String?,
      employeeName: map['employee_name'] as String?,
    );
  }

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? startDate,
    String? endDate,
    String? reason,
    String? status,
    String? approvedBy,
    String? createdAt,
    String? employeeName,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      employeeName: employeeName ?? this.employeeName,
    );
  }

  int get totalDays {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays + 1;
  }
}
