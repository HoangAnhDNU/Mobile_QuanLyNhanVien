import '../in_memory_database.dart';
import '../../../features/attendance/data/models/attendance_model.dart';

class AttendanceDao {
  final _mem = InMemoryDatabase();

  Future<List<Attendance>> getByDate(String date) async {
    final records = _mem.attendance.where((a) => a['date'] == date).toList();
    return records.map((a) {
      final emp = _mem.employees.where((e) => e['id'] == a['employee_id']).firstOrNull;
      return Attendance.fromDbMap({...a, 'employee_name': emp?['full_name']});
    }).toList();
  }

  Future<List<Attendance>> getByEmployee(String employeeId, {int? month, int? year}) async {
    var records = _mem.attendance.where((a) => a['employee_id'] == employeeId);
    if (month != null && year != null) {
      final prefix = '$year-${month.toString().padLeft(2, '0')}';
      records = records.where((a) => (a['date'] as String).startsWith(prefix));
    }
    return records.map((a) {
      final emp = _mem.employees.where((e) => e['id'] == a['employee_id']).firstOrNull;
      return Attendance.fromDbMap({...a, 'employee_name': emp?['full_name']});
    }).toList();
  }

  Future<List<AttendanceSummary>> getSummary(int month, int year) async {
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final activeEmployees = _mem.employees.where((e) => e['status'] == 'active');
    return activeEmployees.map((emp) {
      final records = _mem.attendance.where((a) =>
          a['employee_id'] == emp['id'] && (a['date'] as String).startsWith(prefix));
      return AttendanceSummary(
        employeeId: emp['id'] as String,
        employeeName: emp['full_name'] as String,
        presentDays: records.where((a) => a['status'] == 'present').length,
        absentApproved: records.where((a) => a['status'] == 'absent_approved').length,
        absentUnapproved: records.where((a) => a['status'] == 'absent_unapproved').length,
        lateDays: records.where((a) => a['status'] == 'late').length,
      );
    }).toList()..sort((a, b) => a.employeeName.compareTo(b.employeeName));
  }

  Future<int> countPresentToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _mem.attendance.where((a) =>
        a['date'] == today && (a['status'] == 'present' || a['status'] == 'late')).length;
  }

  Future<int> countOnLeaveToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _mem.leaveRequests.where((l) =>
        l['status'] == 'approved' &&
        (l['start_date'] as String).compareTo(today) <= 0 &&
        (l['end_date'] as String).compareTo(today) >= 0).length;
  }

  Future<void> insertBatch(List<Attendance> records) async {
    for (final record in records) {
      _mem.attendance.removeWhere((a) =>
          a['employee_id'] == record.employeeId && a['date'] == record.date);
      _mem.attendance.add(record.toDbMap());
    }
  }

  Future<void> insert(Attendance attendance) async {
    _mem.attendance.add(attendance.toDbMap());
  }

  Future<void> delete(String id) async {
    _mem.attendance.removeWhere((a) => a['id'] == id);
  }
}
