import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/department_dao.dart';
import '../../data/models/department_model.dart';
import '../../data/models/position_model.dart';

class DepartmentListNotifier extends StateNotifier<AsyncValue<List<Department>>> {
  final DepartmentDao _dao = DepartmentDao();

  DepartmentListNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final departments = await _dao.getAll();
      state = AsyncValue.data(departments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Department department) async {
    await _dao.insert(department);
    await load();
  }

  Future<void> update(Department department) async {
    await _dao.update(department);
    await load();
  }

  Future<void> delete(String id) async {
    await _dao.delete(id);
    await load();
  }
}

final departmentListProvider =
    StateNotifierProvider<DepartmentListNotifier, AsyncValue<List<Department>>>((ref) {
  return DepartmentListNotifier();
});

final positionListProvider = FutureProvider<List<Position>>((ref) async {
  final dao = PositionDao();
  return await dao.getAll();
});
