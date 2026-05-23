import '../in_memory_database.dart';
import '../../../features/department/data/models/department_model.dart';
import '../../../features/department/data/models/position_model.dart';

class DepartmentDao {
  final _mem = InMemoryDatabase();

  Future<List<Department>> getAll() async {
    return _mem.departments.map((d) {
      final manager = _mem.employees.where((e) => e['id'] == d['manager_id']).firstOrNull;
      final empCount = _mem.employees.where((e) =>
          e['department_id'] == d['id'] && e['status'] == 'active').length;
      return Department.fromDbMap({
        ...d,
        'manager_name': manager?['full_name'],
        'employee_count': empCount,
      });
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Department?> getById(String id) async {
    final d = _mem.departments.where((d) => d['id'] == id).firstOrNull;
    if (d == null) return null;
    final manager = _mem.employees.where((e) => e['id'] == d['manager_id']).firstOrNull;
    final empCount = _mem.employees.where((e) =>
        e['department_id'] == d['id'] && e['status'] == 'active').length;
    return Department.fromDbMap({
      ...d,
      'manager_name': manager?['full_name'],
      'employee_count': empCount,
    });
  }

  Future<void> insert(Department department) async {
    _mem.departments.add(department.toDbMap());
  }

  Future<void> update(Department department) async {
    final index = _mem.departments.indexWhere((d) => d['id'] == department.id);
    if (index >= 0) _mem.departments[index] = department.toDbMap();
  }

  Future<void> delete(String id) async {
    _mem.departments.removeWhere((d) => d['id'] == id);
  }
}

class PositionDao {
  final _mem = InMemoryDatabase();

  Future<List<Position>> getAll() async {
    final sorted = List<Map<String, dynamic>>.from(_mem.positions)
      ..sort((a, b) => (a['level'] as int).compareTo(b['level'] as int));
    return sorted.map((p) => Position.fromDbMap(p)).toList();
  }

  Future<Position?> getById(String id) async {
    final p = _mem.positions.where((p) => p['id'] == id).firstOrNull;
    if (p == null) return null;
    return Position.fromDbMap(p);
  }

  Future<void> insert(Position position) async {
    _mem.positions.add(position.toDbMap());
  }

  Future<void> update(Position position) async {
    final index = _mem.positions.indexWhere((p) => p['id'] == position.id);
    if (index >= 0) _mem.positions[index] = position.toDbMap();
  }

  Future<void> delete(String id) async {
    _mem.positions.removeWhere((p) => p['id'] == id);
  }
}
