import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng ban'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      drawer: const AppDrawer(),
      body: Consumer<DepartmentProvider>(
        builder: (context, provider, _) {
          final departments = provider.departments;
          if (departments.isEmpty) {
            return const Center(child: Text('Chưa có phòng ban'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.business, color: AppColors.primary),
                  ),
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${dept.employeeCount} nhân viên${dept.managerName != null ? ' • TP: ${dept.managerName}' : ''}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') _showFormDialog(context, provider, dept);
                      if (value == 'delete') {
                        provider.delete(dept.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa phòng ban')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showFormDialog(context, Provider.of<DepartmentProvider>(context, listen: false), null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, DepartmentProvider provider, Department? dept) {
    final nameCtrl = TextEditingController(text: dept?.name ?? '');
    final descCtrl = TextEditingController(text: dept?.description ?? '');
    final isEditing = dept != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa phòng ban' : 'Thêm phòng ban'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên phòng ban *')),
            const SizedBox(height: 16),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              if (isEditing) {
                provider.update(dept.id, nameCtrl.text.trim(), descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null);
              } else {
                provider.add(nameCtrl.text.trim(), descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }
}
