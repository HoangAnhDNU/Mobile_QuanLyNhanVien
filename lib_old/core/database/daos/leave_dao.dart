import '../in_memory_database.dart';
import '../../../features/leave/data/models/leave_request_model.dart';

class LeaveDao {
  final _mem = InMemoryDatabase();

  Future<List<LeaveRequest>> getAll({String? status, String? employeeId}) async {
    var list = List<Map<String, dynamic>>.from(_mem.leaveRequests);

    if (status != null) {
      list = list.where((l) => l['status'] == status).toList();
    }
    if (employeeId != null) {
      list = list.where((l) => l['employee_id'] == employeeId).toList();
    }

    list.sort((a, b) => (b['created_at'] as String? ?? '').compareTo(a['created_at'] as String? ?? ''));

    return list.map((l) {
      final emp = _mem.employees.where((e) => e['id'] == l['employee_id']).firstOrNull;
      return LeaveRequest.fromDbMap({...l, 'employee_name': emp?['full_name']});
    }).toList();
  }

  Future<int> getUsedDays(String employeeId, int year) async {
    final approved = _mem.leaveRequests.where((l) =>
        l['employee_id'] == employeeId &&
        l['status'] == 'approved' &&
        (l['start_date'] as String).startsWith('$year'));
    int total = 0;
    for (final l in approved) {
      final start = DateTime.parse(l['start_date'] as String);
      final end = DateTime.parse(l['end_date'] as String);
      total += end.difference(start).inDays + 1;
    }
    return total;
  }

  Future<void> insert(LeaveRequest leave) async {
    _mem.leaveRequests.add(leave.toDbMap());
  }

  Future<void> updateStatus(String id, String status, String? approvedBy) async {
    final index = _mem.leaveRequests.indexWhere((l) => l['id'] == id);
    if (index >= 0) {
      _mem.leaveRequests[index]['status'] = status;
      _mem.leaveRequests[index]['approved_by'] = approvedBy;
    }
  }

  Future<void> delete(String id) async {
    _mem.leaveRequests.removeWhere((l) => l['id'] == id);
  }
}
