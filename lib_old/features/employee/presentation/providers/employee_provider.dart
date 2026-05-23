import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../data/models/employee_model.dart';

class EmployeeListState {
  final List<Employee> employees;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? departmentFilter;
  final String? statusFilter;

  const EmployeeListState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.departmentFilter,
    this.statusFilter,
  });

  EmployeeListState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? departmentFilter,
    String? statusFilter,
  }) {
    return EmployeeListState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class EmployeeListNotifier extends StateNotifier<EmployeeListState> {
  final EmployeeDao _dao = EmployeeDao();

  EmployeeListNotifier() : super(const EmployeeListState());

  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await _dao.getAll(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        departmentId: state.departmentFilter,
        status: state.statusFilter,
      );
      state = state.copyWith(employees: employees, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadEmployees();
  }

  Future<void> filterByDepartment(String? departmentId) async {
    state = state.copyWith(departmentFilter: departmentId);
    await loadEmployees();
  }

  Future<void> filterByStatus(String? status) async {
    state = state.copyWith(statusFilter: status);
    await loadEmployees();
  }

  Future<void> deleteEmployee(String id) async {
    await _dao.delete(id);
    await loadEmployees();
  }

  void clearFilters() {
    state = const EmployeeListState();
    loadEmployees();
  }
}

final employeeListProvider =
    StateNotifierProvider<EmployeeListNotifier, EmployeeListState>((ref) {
  return EmployeeListNotifier();
});

final employeeDetailProvider =
    FutureProvider.family<Employee?, String>((ref, id) async {
  final dao = EmployeeDao();
  return await dao.getById(id);
});
