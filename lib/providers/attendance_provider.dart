import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String date;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.status,
  });
}

class AttendanceSummary {
  final String employeeId;
  final String employeeName;
  final int presentDays;
  final int lateDays;
  final int absentApproved;
  final int absentUnapproved;

  AttendanceSummary({
    required this.employeeId,
    required this.employeeName,
    required this.presentDays,
    required this.lateDays,
    required this.absentApproved,
    required this.absentUnapproved,
  });
}

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceRecord> _records = [];
  List<AttendanceSummary> _summary = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<AttendanceRecord> get records => List.unmodifiable(_records);
  List<AttendanceSummary> get summary => _summary;
  bool get isLoading => _isLoading;

  List<AttendanceRecord> getByDate(String date) {
    return _records.where((r) => r.date == date).toList();
  }

  void saveBatch(List<AttendanceRecord> newRecords) {
    for (final r in newRecords) {
      _records.removeWhere((rec) => rec.employeeId == r.employeeId && rec.date == r.date);
      _records.add(r);
    }
    notifyListeners();
  }

  AttendanceRecord createRecord({
    required String employeeId,
    required String employeeName,
    required String date,
    required String status,
  }) {
    return AttendanceRecord(
      id: _uuid.v4(),
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      status: status,
    );
  }

  void loadSummary(int month, int year, List<Map<String, String>> activeEmployees) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    _summary = activeEmployees.map((emp) {
      final empRecords = _records.where((r) =>
          r.employeeId == emp['id'] && r.date.startsWith(prefix));
      return AttendanceSummary(
        employeeId: emp['id']!,
        employeeName: emp['name']!,
        presentDays: empRecords.where((r) => r.status == 'present').length,
        lateDays: empRecords.where((r) => r.status == 'late').length,
        absentApproved: empRecords.where((r) => r.status == 'absent_approved').length,
        absentUnapproved: empRecords.where((r) => r.status == 'absent_unapproved').length,
      );
    }).toList();
    notifyListeners();
  }
}
