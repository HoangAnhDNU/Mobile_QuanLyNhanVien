import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class InMemoryDatabase {
  static final InMemoryDatabase _instance = InMemoryDatabase._();
  factory InMemoryDatabase() => _instance;
  InMemoryDatabase._() {
    _seedData();
  }

  static bool get isWeb => kIsWeb;

  final List<Map<String, dynamic>> users = [];
  final List<Map<String, dynamic>> departments = [];
  final List<Map<String, dynamic>> positions = [];
  final List<Map<String, dynamic>> employees = [];
  final List<Map<String, dynamic>> attendance = [];
  final List<Map<String, dynamic>> salaries = [];
  final List<Map<String, dynamic>> leaveRequests = [];

  void _seedData() {
    const uuid = Uuid();

    // Users
    users.addAll([
      {
        'id': 'user_001',
        'username': 'admin',
        'password_hash': 'admin123',
        'role': 'admin',
        'employee_id': null,
        'status': 'active',
        'created_at': '2024-01-01T00:00:00',
      },
      {
        'id': 'user_002',
        'username': 'manager',
        'password_hash': 'manager123',
        'role': 'manager',
        'employee_id': 'emp_001',
        'status': 'active',
        'created_at': '2024-01-01T00:00:00',
      },
    ]);

    // Departments
    departments.addAll([
      {'id': 'dept_001', 'name': 'Phòng Kỹ thuật', 'manager_id': 'emp_001', 'description': 'Phòng phát triển phần mềm', 'created_at': '2024-01-01'},
      {'id': 'dept_002', 'name': 'Phòng Nhân sự', 'manager_id': 'emp_002', 'description': 'Quản lý nhân sự và tuyển dụng', 'created_at': '2024-01-01'},
      {'id': 'dept_003', 'name': 'Phòng Kinh doanh', 'manager_id': 'emp_007', 'description': 'Kinh doanh và bán hàng', 'created_at': '2024-01-01'},
      {'id': 'dept_004', 'name': 'Phòng Tài chính', 'manager_id': null, 'description': 'Kế toán và tài chính', 'created_at': '2024-01-01'},
      {'id': 'dept_005', 'name': 'Phòng Marketing', 'manager_id': null, 'description': 'Marketing và truyền thông', 'created_at': '2024-01-01'},
    ]);

    // Positions
    positions.addAll([
      {'id': 'pos_001', 'name': 'Giám đốc', 'level': 1, 'allowance': 5000000, 'created_at': '2024-01-01'},
      {'id': 'pos_002', 'name': 'Phó Giám đốc', 'level': 2, 'allowance': 4000000, 'created_at': '2024-01-01'},
      {'id': 'pos_003', 'name': 'Trưởng phòng', 'level': 3, 'allowance': 3000000, 'created_at': '2024-01-01'},
      {'id': 'pos_004', 'name': 'Phó phòng', 'level': 4, 'allowance': 2000000, 'created_at': '2024-01-01'},
      {'id': 'pos_005', 'name': 'Nhóm trưởng', 'level': 5, 'allowance': 1500000, 'created_at': '2024-01-01'},
      {'id': 'pos_006', 'name': 'Nhân viên', 'level': 6, 'allowance': 500000, 'created_at': '2024-01-01'},
      {'id': 'pos_007', 'name': 'Thực tập sinh', 'level': 7, 'allowance': 0, 'created_at': '2024-01-01'},
    ]);

    // Employees
    employees.addAll([
      {'id': 'emp_001', 'employee_code': 'NV001', 'full_name': 'Nguyễn Văn An', 'date_of_birth': '1990-05-15', 'gender': 'male', 'department_id': 'dept_001', 'position_id': 'pos_003', 'phone': '0901234567', 'email': 'nguyenvanan@company.com', 'start_date': '2020-01-15', 'contract_type': 'full_time', 'base_salary': 20000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_002', 'employee_code': 'NV002', 'full_name': 'Trần Thị Bích', 'date_of_birth': '1992-08-20', 'gender': 'female', 'department_id': 'dept_002', 'position_id': 'pos_003', 'phone': '0987654321', 'email': 'tranthibich@company.com', 'start_date': '2021-03-01', 'contract_type': 'full_time', 'base_salary': 18000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_003', 'employee_code': 'NV003', 'full_name': 'Lê Hoàng Cường', 'date_of_birth': '1988-12-03', 'gender': 'male', 'department_id': 'dept_001', 'position_id': 'pos_005', 'phone': '0912345678', 'email': 'lehoangcuong@company.com', 'start_date': '2019-06-10', 'contract_type': 'full_time', 'base_salary': 15000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_004', 'employee_code': 'NV004', 'full_name': 'Phạm Thị Dung', 'date_of_birth': '1995-03-22', 'gender': 'female', 'department_id': 'dept_003', 'position_id': 'pos_006', 'phone': '0923456789', 'email': 'phamthidung@company.com', 'start_date': '2022-09-01', 'contract_type': 'full_time', 'base_salary': 12000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_005', 'employee_code': 'NV005', 'full_name': 'Hoàng Văn Em', 'date_of_birth': '1991-07-14', 'gender': 'male', 'department_id': 'dept_004', 'position_id': 'pos_006', 'phone': '0934567890', 'email': 'hoangvanem@company.com', 'start_date': '2021-11-15', 'contract_type': 'full_time', 'base_salary': 14000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_006', 'employee_code': 'NV006', 'full_name': 'Vũ Thị Phương', 'date_of_birth': '1993-01-30', 'gender': 'female', 'department_id': 'dept_001', 'position_id': 'pos_006', 'phone': '0945678901', 'email': 'vuthiphuong@company.com', 'start_date': '2023-02-01', 'contract_type': 'full_time', 'base_salary': 13000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_007', 'employee_code': 'NV007', 'full_name': 'Đỗ Minh Quang', 'date_of_birth': '1987-09-08', 'gender': 'male', 'department_id': 'dept_003', 'position_id': 'pos_003', 'phone': '0956789012', 'email': 'dominhquang@company.com', 'start_date': '2018-04-20', 'contract_type': 'full_time', 'base_salary': 22000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_008', 'employee_code': 'NV008', 'full_name': 'Ngô Thanh Hà', 'date_of_birth': '1996-11-25', 'gender': 'female', 'department_id': 'dept_005', 'position_id': 'pos_006', 'phone': '0967890123', 'email': 'ngothanhha@company.com', 'start_date': '2023-07-10', 'contract_type': 'intern', 'base_salary': 8000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_009', 'employee_code': 'NV009', 'full_name': 'Bùi Đức Hải', 'date_of_birth': '1989-04-17', 'gender': 'male', 'department_id': 'dept_001', 'position_id': 'pos_004', 'phone': '0978901234', 'email': 'buiduchai@company.com', 'start_date': '2019-01-05', 'contract_type': 'full_time', 'base_salary': 19000000, 'status': 'on_leave', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_010', 'employee_code': 'NV010', 'full_name': 'Lý Thị Kim', 'date_of_birth': '1994-06-12', 'gender': 'female', 'department_id': 'dept_002', 'position_id': 'pos_006', 'phone': '0989012345', 'email': 'lythikim@company.com', 'start_date': '2020-08-15', 'contract_type': 'full_time', 'base_salary': 13500000, 'status': 'resigned', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_011', 'employee_code': 'NV011', 'full_name': 'Trương Văn Long', 'date_of_birth': '1990-10-05', 'gender': 'male', 'department_id': 'dept_005', 'position_id': 'pos_005', 'phone': '0991234567', 'email': 'truongvanlong@company.com', 'start_date': '2022-03-15', 'contract_type': 'full_time', 'base_salary': 16000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-01', 'updated_at': '2024-01-01'},
      {'id': 'emp_012', 'employee_code': 'NV012', 'full_name': 'Mai Thị Ngọc', 'date_of_birth': '1997-02-28', 'gender': 'female', 'department_id': 'dept_004', 'position_id': 'pos_006', 'phone': '0902345678', 'email': 'maithingoc@company.com', 'start_date': '2024-01-10', 'contract_type': 'full_time', 'base_salary': 11000000, 'status': 'active', 'avatar_url': null, 'created_at': '2024-01-10', 'updated_at': '2024-01-10'},
    ]);

    // Attendance sample (today and yesterday)
    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    for (final emp in employees.where((e) => e['status'] == 'active')) {
      attendance.add({
        'id': uuid.v4(),
        'employee_id': emp['id'],
        'date': today,
        'status': 'present',
        'check_in_time': '08:00:00',
        'check_out_time': '17:30:00',
        'note': null,
        'created_at': today,
      });
      attendance.add({
        'id': uuid.v4(),
        'employee_id': emp['id'],
        'date': yesterday,
        'status': emp['id'] == 'emp_003' ? 'late' : 'present',
        'check_in_time': emp['id'] == 'emp_003' ? '08:45:00' : '08:00:00',
        'check_out_time': '17:30:00',
        'note': null,
        'created_at': yesterday,
      });
    }

    // Leave requests
    leaveRequests.addAll([
      {'id': 'leave_001', 'employee_id': 'emp_009', 'start_date': '2024-12-20', 'end_date': '2024-12-25', 'reason': 'Nghỉ phép năm', 'status': 'approved', 'approved_by': 'user_001', 'created_at': '2024-12-15'},
      {'id': 'leave_002', 'employee_id': 'emp_003', 'start_date': '2025-01-10', 'end_date': '2025-01-12', 'reason': 'Việc gia đình', 'status': 'approved', 'approved_by': 'user_001', 'created_at': '2025-01-05'},
      {'id': 'leave_003', 'employee_id': 'emp_006', 'start_date': '2025-02-01', 'end_date': '2025-02-03', 'reason': 'Khám bệnh', 'status': 'pending', 'approved_by': null, 'created_at': '2025-01-28'},
      {'id': 'leave_004', 'employee_id': 'emp_004', 'start_date': '2025-02-10', 'end_date': '2025-02-14', 'reason': 'Du lịch', 'status': 'pending', 'approved_by': null, 'created_at': '2025-02-01'},
      {'id': 'leave_005', 'employee_id': 'emp_005', 'start_date': '2025-01-20', 'end_date': '2025-01-20', 'reason': 'Việc cá nhân', 'status': 'rejected', 'approved_by': 'user_001', 'created_at': '2025-01-18'},
    ]);
  }
}
