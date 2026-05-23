import '../in_memory_database.dart';
import '../../../features/employee/data/models/employee_model.dart';

class EmployeeDao {
  final _mem = InMemoryDatabase();

  Future<List<Employee>> getAll({
    String? search,
    String? departmentId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    var list = List<Map<String, dynamic>>.from(_mem.employees);

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((e) =>
          (e['full_name'] as String).toLowerCase().contains(s) ||
          (e['employee_code'] as String).toLowerCase().contains(s)).toList();
    }
    if (departmentId != null) {
      list = list.where((e) => e['department_id'] == departmentId).toList();
    }
    if (status != null) {
      list = list.where((e) => e['status'] == status).toList();
    }

    list.sort((a, b) => (a['full_name'] as String).compareTo(b['full_name'] as String));
    final offset = (page - 1) * limit;
    final paged = list.skip(offset).take(limit).toList();

    return paged.map((e) {
      final dept = _mem.departments.where((d) => d['id'] == e['department_id']).firstOrNull;
      final pos = _mem.positions.where((p) => p['id'] == e['position_id']).firstOrNull;
      return Employee.fromDbMap({
        ...e,
        'department_name': dept?['name'],
        'position_name': pos?['name'],
      });
    }).toList();
  }

  Future<int> count({String? status}) async {
    if (status != null) {
      return _mem.employees.where((e) => e['status'] == status).length;
    }
    return _mem.employees.length;
  }

  Future<int> countNewThisMonth() async {
    final now = DateTime.now();
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    return _mem.employees.where((e) =>
        (e['start_date'] as String? ?? '').compareTo(monthStart) >= 0).length;
  }

  Future<Employee?> getById(String id) async {
    final e = _mem.employees.where((e) => e['id'] == id).firstOrNull;
    if (e == null) return null;
    final dept = _mem.departments.where((d) => d['id'] == e['department_id']).firstOrNull;
    final pos = _mem.positions.where((p) => p['id'] == e['position_id']).firstOrNull;
    return Employee.fromDbMap({
      ...e,
      'department_name': dept?['name'],
      'position_name': pos?['name'],
    });
  }

  Future<bool> isCodeExists(String code, [String? excludeId]) async {
    return _mem.employees.any((e) =>
        e['employee_code'] == code && (excludeId == null || e['id'] != excludeId));
  }

  Future<void> insert(Employee employee) async {
    _mem.employees.add(employee.toDbMap());
  }

  Future<void> update(Employee employee) async {
    final index = _mem.employees.indexWhere((e) => e['id'] == employee.id);
    if (index >= 0) _mem.employees[index] = employee.toDbMap();
  }

  Future<void> delete(String id) async {
    _mem.employees.removeWhere((e) => e['id'] == id);
  }

  Future<List<Map<String, dynamic>>> countByDepartment() async {
    final result = <Map<String, dynamic>>[];
    for (final dept in _mem.departments) {
      final count = _mem.employees.where((e) =>
          e['department_id'] == dept['id'] && e['status'] == 'active').length;
      result.add({'department_name': dept['name'], 'count': count});
    }
    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return result;
  }

  Future<Map<String, int>> countByGender() async {
    final map = <String, int>{};
    for (final e in _mem.employees.where((e) => e['status'] == 'active')) {
      final gender = e['gender'] as String? ?? 'other';
      map[gender] = (map[gender] ?? 0) + 1;
    }
    return map;
  }

  Future<List<Employee>> getByDepartment(String departmentId) async {
    return getAll(departmentId: departmentId, limit: 1000);
  }
}
