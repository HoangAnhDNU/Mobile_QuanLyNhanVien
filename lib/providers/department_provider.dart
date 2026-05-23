import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Department {
  final String id;
  final String name;
  final String? description;
  final String? managerId;
  final String? managerName;
  final int employeeCount;

  Department({
    required this.id,
    required this.name,
    this.description,
    this.managerId,
    this.managerName,
    this.employeeCount = 0,
  });
}

class DepartmentProvider extends ChangeNotifier {
  final List<Department> _departments = [];
  final _uuid = const Uuid();

  List<Department> get departments => List.unmodifiable(_departments);

  DepartmentProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _departments.addAll([
      Department(id: _uuid.v4(), name: 'Phòng Kỹ thuật', description: 'Phát triển phần mềm', managerName: 'Nguyễn Văn An', employeeCount: 3),
      Department(id: _uuid.v4(), name: 'Phòng Nhân sự', description: 'Quản lý nhân sự', managerName: 'Trần Thị Bích', employeeCount: 1),
      Department(id: _uuid.v4(), name: 'Phòng Kinh doanh', description: 'Kinh doanh và bán hàng', managerName: 'Đỗ Minh Quang', employeeCount: 2),
      Department(id: _uuid.v4(), name: 'Phòng Tài chính', description: 'Kế toán và tài chính', employeeCount: 2),
      Department(id: _uuid.v4(), name: 'Phòng Marketing', description: 'Marketing và truyền thông', employeeCount: 2),
    ]);
  }

  void add(String name, String? description) {
    _departments.add(Department(id: _uuid.v4(), name: name, description: description));
    notifyListeners();
  }

  void update(String id, String name, String? description) {
    final index = _departments.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _departments[index] = Department(
        id: id,
        name: name,
        description: description,
        managerId: _departments[index].managerId,
        managerName: _departments[index].managerName,
        employeeCount: _departments[index].employeeCount,
      );
      notifyListeners();
    }
  }

  void delete(String id) {
    _departments.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}
