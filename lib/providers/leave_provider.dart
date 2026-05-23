import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class LeaveRequest {
  final String id;
  final String employeeId;
  final String? employeeName;
  final String startDate;
  final String endDate;
  final String? reason;
  final String status;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status = 'pending',
  });

  int get totalDays {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays + 1;
  }

  LeaveRequest copyWith({String? status}) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status ?? this.status,
    );
  }
}

class LeaveProvider extends ChangeNotifier {
  final List<LeaveRequest> _requests = [];
  final _uuid = const Uuid();

  LeaveProvider() {
    _loadSampleData();
  }

  List<LeaveRequest> get allRequests => List.unmodifiable(_requests);

  List<LeaveRequest> getByStatus(String status) {
    return _requests.where((r) => r.status == status).toList();
  }

  void _loadSampleData() {
    _requests.addAll([
      LeaveRequest(id: _uuid.v4(), employeeId: 'emp_005', employeeName: 'Hoàng Văn Em', startDate: '2025-01-10', endDate: '2025-01-12', reason: 'Việc gia đình', status: 'approved'),
      LeaveRequest(id: _uuid.v4(), employeeId: 'emp_004', employeeName: 'Phạm Thị Dung', startDate: '2025-02-10', endDate: '2025-02-14', reason: 'Du lịch', status: 'pending'),
      LeaveRequest(id: _uuid.v4(), employeeId: 'emp_006', employeeName: 'Vũ Thị Phương', startDate: '2025-02-01', endDate: '2025-02-03', reason: 'Khám bệnh', status: 'pending'),
      LeaveRequest(id: _uuid.v4(), employeeId: 'emp_003', employeeName: 'Lê Hoàng Cường', startDate: '2025-01-20', endDate: '2025-01-20', reason: 'Việc cá nhân', status: 'rejected'),
    ]);
  }

  void create(LeaveRequest request) {
    _requests.add(LeaveRequest(
      id: _uuid.v4(),
      employeeId: request.employeeId,
      employeeName: request.employeeName,
      startDate: request.startDate,
      endDate: request.endDate,
      reason: request.reason,
      status: 'pending',
    ));
    notifyListeners();
  }

  void approve(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: 'approved');
      notifyListeners();
    }
  }

  void reject(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: 'rejected');
      notifyListeners();
    }
  }

  void delete(String id) {
    _requests.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
