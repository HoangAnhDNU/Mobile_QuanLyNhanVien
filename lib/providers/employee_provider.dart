import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';

class EmployeeProvider extends ChangeNotifier {
  final List<Employee> _employees = [];
  final _uuid = const Uuid();

  List<Employee> get employees => List.unmodifiable(_employees);

  EmployeeProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _employees.addAll([
      Employee(
        id: _uuid.v4(),
        employeeCode: 'NV001',
        fullName: 'Nguyễn Văn An',
        dateOfBirth: '1990-05-15',
        gender: 'Nam',
        department: 'Phòng Kỹ thuật',
        position: 'Trưởng phòng',
        phone: '0901234567',
        email: 'nguyenvanan@company.com',
        startDate: '2020-01-15',
        baseSalary: 20000000,
        status: 'Đang làm',
      ),
      Employee(
        id: _uuid.v4(),
        employeeCode: 'NV002',
        fullName: 'Trần Thị Bích',
        dateOfBirth: '1992-08-20',
        gender: 'Nữ',
        department: 'Phòng Nhân sự',
        position: 'Trưởng phòng',
        phone: '0987654321',
        email: 'tranthibich@company.com',
        startDate: '2021-03-01',
        baseSalary: 18000000,
        status: 'Đang làm',
      ),
      Employee(
        id: _uuid.v4(),
        employeeCode: 'NV003',
        fullName: 'Lê Hoàng Cường',
        dateOfBirth: '1988-12-03',
        gender: 'Nam',
        department: 'Phòng Kỹ thuật',
        position: 'Nhóm trưởng',
        phone: '0912345678',
        email: 'lehoangcuong@company.com',
        startDate: '2019-06-10',
        baseSalary: 15000000,
        status: 'Đang làm',
      ),
      Employee(
        id: _uuid.v4(),
        employeeCode: 'NV004',
        fullName: 'Phạm Thị Dung',
        dateOfBirth: '1995-03-22',
        gender: 'Nữ',
        department: 'Phòng Kinh doanh',
        position: 'Nhân viên',
        phone: '0923456789',
        email: 'phamthidung@company.com',
        startDate: '2022-09-01',
        baseSalary: 12000000,
        status: 'Đang làm',
      ),
      Employee(
        id: _uuid.v4(),
        employeeCode: 'NV005',
        fullName: 'Hoàng Văn Em',
        dateOfBirth: '1991-07-14',
        gender: 'Nam',
        department: 'Phòng Tài chính',
        position: 'Nhân viên',
        phone: '0934567890',
        email: 'hoangvanem@company.com',
        startDate: '2021-11-15',
        baseSalary: 14000000,
        status: 'Nghỉ phép',
      ),
    ]);
  }

  Employee? getById(String id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addEmployee(Employee employee) {
    final newEmployee = Employee(
      id: _uuid.v4(),
      employeeCode: employee.employeeCode,
      fullName: employee.fullName,
      dateOfBirth: employee.dateOfBirth,
      gender: employee.gender,
      department: employee.department,
      position: employee.position,
      phone: employee.phone,
      email: employee.email,
      startDate: employee.startDate,
      baseSalary: employee.baseSalary,
      status: employee.status,
    );
    _employees.add(newEmployee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index >= 0) {
      _employees[index] = employee;
      notifyListeners();
    }
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
