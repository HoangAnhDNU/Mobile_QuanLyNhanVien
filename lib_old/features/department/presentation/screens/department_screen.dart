import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../data/models/department_model.dart';
import '../providers/department_provider.dart';

class DepartmentScreen extends ConsumerStatefulWidget {
  const DepartmentScreen({super.key});

  @override
  ConsumerState<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends ConsumerState<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final departmentsState = ref.watch(departmentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Phòng ban')),
      drawer: const AppDrawer(),
      body: departmentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (departments) {
          if (departments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.business_outlined,
              title: 'Chưa có phòng ban',
              subtitle: 'Nhấn + để thêm phòng ban mới',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.business),
                  ),
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${dept.employeeCount ?? 0} nhân viên${dept.managerName != null ? ' • TP: ${dept.managerName}' : ''}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') _showFormDialog(context, department: dept);
                      if (value == 'delete') _deleteDepartment(dept);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFormDialog(BuildContext context, {Department? department}) {
    final nameController = TextEditingController(text: department?.name ?? '');
    final descController = TextEditingController(text: department?.description ?? '');
    final isEditing = department != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa phòng ban' : 'Thêm phòng ban'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên phòng ban *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final dept = Department(
                id: isEditing ? department!.id : const Uuid().v4(),
                name: nameController.text.trim(),
                description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                managerId: department?.managerId,
              );
              if (isEditing) {
                ref.read(departmentListProvider.notifier).update(dept);
              } else {
                ref.read(departmentListProvider.notifier).add(dept);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Đã cập nhật phòng ban' : 'Đã thêm phòng ban'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _deleteDepartment(Department dept) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa phòng ban',
      content: 'Bạn có chắc muốn xóa phòng ban "${dept.name}"?',
      confirmText: 'Xóa',
    );
    if (confirmed == true) {
      ref.read(departmentListProvider.notifier).delete(dept.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa phòng ban'), backgroundColor: Colors.green),
        );
      }
    }
  }
}
