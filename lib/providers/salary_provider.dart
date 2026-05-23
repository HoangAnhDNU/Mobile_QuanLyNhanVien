import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import 'attendance_provider.dart';

class Salary {
  final String id;
  final String employeeId;
  final String? employeeName;
  final int month;
  final int year;
  final double baseSalary;
  final int workDays;
  final double allowance;
  final double deduction;
  final double netSalary;

  Salary({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.workDays,
    required this.allowance,
    required this.deduction,
    required this.netSalary,
  });
}

class SalaryProvider extends ChangeNotifier {
  final List<Salary> _salaries = [];
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final _uuid = const Uuid();

  List<Salary> get salaries => _salaries.where((s) =>
      s.month == _selectedMonth && s.year == _selectedYear).toList();
  bool get isLoading => _isLoading;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  void setMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  void calculateSalaries(List<Employee> employees, AttendanceProvider attendanceProvider) {
    _isLoading = true;
    notifyListeners();

    _salaries.removeWhere((s) => s.month == _selectedMonth && s.year == _selectedYear);

    final prefix = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
    const standardDays = 22;

    for (final emp in employees.where((e) => e.status == 'Đang làm')) {
      final records = attendanceProvider.records.where((r) =>
          r.employeeId == emp.id && r.date.startsWith(prefix));
      final workDays = records.where((r) => r.status == 'present' || r.status == 'late').length;
      final dailySalary = emp.baseSalary / standardDays;
      final allowance = 500000;
      final netSalary = (dailySalary * workDays) + allowance;

      _salaries.add(Salary(
        id: _uuid.v4(),
        employeeId: emp.id,
        employeeName: emp.fullName,
        month: _selectedMonth,
        year: _selectedYear,
        baseSalary: emp.baseSalary,
        workDays: workDays,
        allowance: allowance.toDouble(),
        deduction: 0,
        netSalary: netSalary,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }
}
