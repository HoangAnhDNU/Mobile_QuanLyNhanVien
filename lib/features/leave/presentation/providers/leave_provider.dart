import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/leave_dao.dart';
import '../../data/models/leave_request_model.dart';

class LeaveState {
  final List<LeaveRequest> requests;
  final bool isLoading;
  final String? error;
  final String? filterStatus;

  const LeaveState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  LeaveState copyWith({
    List<LeaveRequest>? requests,
    bool? isLoading,
    String? error,
    String? filterStatus,
  }) {
    return LeaveState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveDao _dao = LeaveDao();

  LeaveNotifier() : super(const LeaveState());

  Future<void> load({String? status}) async {
    state = state.copyWith(isLoading: true, filterStatus: status, error: null);
    try {
      final requests = await _dao.getAll(status: status);
      state = state.copyWith(requests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create(LeaveRequest request) async {
    await _dao.insert(request);
    await load(status: state.filterStatus);
  }

  Future<void> approve(String id, String approvedBy) async {
    await _dao.updateStatus(id, 'approved', approvedBy);
    await load(status: state.filterStatus);
  }

  Future<void> reject(String id, String approvedBy) async {
    await _dao.updateStatus(id, 'rejected', approvedBy);
    await load(status: state.filterStatus);
  }

  Future<int> getRemainingDays(String employeeId) async {
    final year = DateTime.now().year;
    final used = await _dao.getUsedDays(employeeId, year);
    return 12 - used;
  }
}

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier();
});
