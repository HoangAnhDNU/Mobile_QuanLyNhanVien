import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/salary_dao.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../core/database/daos/attendance_dao.dart';
import '../../../../core/database/daos/department_dao.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/models/salary_model.dart';

class SalaryState {
  final List<Salary> salaries;
  final bool isLoading;
  final String? error;
  final int selectedMonth;
  final int selectedYear;

  SalaryState({
    this.salaries = const [],
    this.isLoading = false,
    this.error,
    int? selectedMonth,
    int? selectedYear,
  })  : selectedMonth = selectedMonth ?? DateTime.now().month,
        selectedYear = selectedYear ?? DateTime.now().year;

  SalaryState copyWith({
    List<Salary>? salaries,
    bool? isLoading,
    String? error,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return SalaryState(
      salaries: salaries ?? this.salaries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class SalaryNotifier extends StateNotifier<SalaryState> {
  final SalaryDao _salaryDao = SalaryDao();
  final EmployeeDao _employeeDao = EmployeeDao();
  final AttendanceDao _attendanceDao = AttendanceDao();
  final PositionDao _positionDao = PositionDao();
  final _uuid = const Uuid();

  SalaryNotifier() : super(SalaryState());

  Future<void> loadSalaries(int month, int year) async {
    state = state.copyWith(
      isLoading: true,
      selectedMonth: month,
      selectedYear: year,
      error: null,
    );
    try {
      final salaries = await _salaryDao.getByMonth(month, year);
      state = state.copyWith(salaries: salaries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> calculateSalaries() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final month = state.selectedMonth;
      final year = state.selectedYear;
      final employees = await _employeeDao.getAll(status: 'active');
      final summaries = await _attendanceDao.getSummary(month, year);
      final standardDays = AppSizes.standardWorkDays;

      final salaries = <Salary>[];
      for (final employee in employees) {
        final summary = summaries.firstWhere(
          (s) => s.employeeId == employee.id,
          orElse: () => AttendanceSummary(
            employeeId: employee.id,
            employeeName: employee.fullName,
          ),
        );

        // Get position allowance
        double positionAllowance = 0;
        if (employee.positionId != null) {
          final position = await _positionDao.getById(employee.positionId!);
          positionAllowance = position?.allowance ?? 0;
        }

        final workDays = summary.presentDays + summary.lateDays;
        final baseSalary = employee.baseSalary;
        final dailySalary = baseSalary / standardDays;
        final earnedSalary = dailySalary * workDays;

        // Allowances: position + lunch (30k/day) + transport (500k/month)
        final lunchAllowance = workDays * 30000.0;
        const transportAllowance = 500000.0;
        final totalAllowance = positionAllowance + lunchAllowance + transportAllowance;

        // Deductions: BHXH 8% + BHYT 1.5% + BHTN 1% = 10.5%
        final insuranceDeduction = baseSalary * 0.105;
        // Basic tax (simplified): 0 if salary < 11M, 5% of excess
        final taxableIncome = earnedSalary + totalAllowance - insuranceDeduction - 11000000;
        final tax = taxableIncome > 0 ? taxableIncome * 0.05 : 0.0;
        final totalDeduction = insuranceDeduction + tax;

        final netSalary = earnedSalary + totalAllowance - totalDeduction;

        salaries.add(Salary(
          id: _uuid.v4(),
          employeeId: employee.id,
          month: month,
          year: year,
          workDays: workDays,
          baseSalary: baseSalary,
          allowance: totalAllowance,
          deduction: totalDeduction,
          netSalary: netSalary > 0 ? netSalary : 0,
          employeeName: employee.fullName,
        ));
      }

      // Delete old and insert new
      await _salaryDao.deleteByMonth(month, year);
      await _salaryDao.insertBatch(salaries);
      state = state.copyWith(salaries: salaries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final salaryProvider = StateNotifierProvider<SalaryNotifier, SalaryState>((ref) {
  return SalaryNotifier();
});
