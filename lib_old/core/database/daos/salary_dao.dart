import '../in_memory_database.dart';
import '../../../features/salary/data/models/salary_model.dart';

class SalaryDao {
  final _mem = InMemoryDatabase();

  Future<List<Salary>> getByMonth(int month, int year) async {
    final records = _mem.salaries.where((s) => s['month'] == month && s['year'] == year).toList();
    return records.map((s) {
      final emp = _mem.employees.where((e) => e['id'] == s['employee_id']).firstOrNull;
      return Salary.fromDbMap({...s, 'employee_name': emp?['full_name']});
    }).toList()..sort((a, b) => (a.employeeName ?? '').compareTo(b.employeeName ?? ''));
  }

  Future<List<Salary>> getByEmployee(String employeeId) async {
    final records = _mem.salaries.where((s) => s['employee_id'] == employeeId).toList();
    records.sort((a, b) {
      final yearCmp = (b['year'] as int).compareTo(a['year'] as int);
      if (yearCmp != 0) return yearCmp;
      return (b['month'] as int).compareTo(a['month'] as int);
    });
    return records.map((s) {
      final emp = _mem.employees.where((e) => e['id'] == s['employee_id']).firstOrNull;
      return Salary.fromDbMap({...s, 'employee_name': emp?['full_name']});
    }).toList();
  }

  Future<Salary?> getByEmployeeMonth(String employeeId, int month, int year) async {
    final s = _mem.salaries.where((s) =>
        s['employee_id'] == employeeId && s['month'] == month && s['year'] == year).firstOrNull;
    if (s == null) return null;
    final emp = _mem.employees.where((e) => e['id'] == s['employee_id']).firstOrNull;
    return Salary.fromDbMap({...s, 'employee_name': emp?['full_name']});
  }

  Future<void> insert(Salary salary) async {
    _mem.salaries.removeWhere((s) =>
        s['employee_id'] == salary.employeeId && s['month'] == salary.month && s['year'] == salary.year);
    _mem.salaries.add(salary.toDbMap());
  }

  Future<void> insertBatch(List<Salary> salaries) async {
    for (final salary in salaries) {
      await insert(salary);
    }
  }

  Future<void> delete(String id) async {
    _mem.salaries.removeWhere((s) => s['id'] == id);
  }

  Future<void> deleteByMonth(int month, int year) async {
    _mem.salaries.removeWhere((s) => s['month'] == month && s['year'] == year);
  }
}
