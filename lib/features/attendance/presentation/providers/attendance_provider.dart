import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/attendance_dao.dart';
import '../../data/models/attendance_model.dart';

class AttendanceState {
  final List<Attendance> records;
  final List<AttendanceSummary> summary;
  final bool isLoading;
  final String? error;
  final String selectedDate;

  AttendanceState({
    this.records = const [],
    this.summary = const [],
    this.isLoading = false,
    this.error,
    String? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now().toIso8601String().split('T')[0];

  AttendanceState copyWith({
    List<Attendance>? records,
    List<AttendanceSummary>? summary,
    bool? isLoading,
    String? error,
    String? selectedDate,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceDao _dao = AttendanceDao();

  AttendanceNotifier() : super(AttendanceState());

  Future<void> loadByDate(String date) async {
    state = state.copyWith(isLoading: true, selectedDate: date, error: null);
    try {
      final records = await _dao.getByDate(date);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadSummary(int month, int year) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _dao.getSummary(month, year);
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveBatch(List<Attendance> records) async {
    await _dao.insertBatch(records);
    await loadByDate(state.selectedDate);
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier();
});
