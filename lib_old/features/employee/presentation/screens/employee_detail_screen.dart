import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/employee_provider.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/employees/form/$employeeId'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Xóa nhân viên',
                content: 'Bạn có chắc chắn muốn xóa nhân viên này?',
                confirmText: 'Xóa',
              );
              if (confirmed == true) {
                await ref.read(employeeListProvider.notifier).deleteEmployee(employeeId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa nhân viên'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: employeeAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (employee) {
          if (employee == null) {
            return const Center(child: Text('Không tìm thấy nhân viên'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            child: Column(
              children: [
                // Avatar and name
                CircleAvatar(
                  radius: AppSizes.avatarXL / 2,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    employee.fullName.isNotEmpty ? employee.fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMD),
                Text(
                  employee.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  employee.employeeCode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(Formatters.employeeStatusDisplay(employee.status)),
                  backgroundColor: _getStatusColor(employee.status).withOpacity(0.1),
                  side: BorderSide(color: _getStatusColor(employee.status).withOpacity(0.5)),
                ),
                const SizedBox(height: AppSizes.spacingLG),

                // Info sections
                _buildInfoSection(context, 'Thông tin cá nhân', [
                  _InfoRow('Ngày sinh', employee.dateOfBirth != null
                      ? AppDateUtils.formatDate(DateTime.parse(employee.dateOfBirth!))
                      : 'Chưa cập nhật'),
                  _InfoRow('Giới tính', Formatters.genderDisplay(employee.gender ?? '')),
                  _InfoRow('Điện thoại', employee.phone ?? 'Chưa cập nhật'),
                  _InfoRow('Email', employee.email ?? 'Chưa cập nhật'),
                ]),
                const SizedBox(height: AppSizes.spacingMD),

                _buildInfoSection(context, 'Thông tin công việc', [
                  _InfoRow('Phòng ban', employee.departmentName ?? 'Chưa xếp phòng'),
                  _InfoRow('Chức vụ', employee.positionName ?? 'Chưa xếp'),
                  _InfoRow('Ngày vào làm', employee.startDate != null
                      ? AppDateUtils.formatDate(DateTime.parse(employee.startDate!))
                      : 'Chưa cập nhật'),
                  _InfoRow('Loại HĐ', Formatters.contractTypeDisplay(employee.contractType ?? '')),
                  _InfoRow('Lương cơ bản', Formatters.currency(employee.baseSalary)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<_InfoRow> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          row.label,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'on_leave':
        return Colors.orange;
      case 'resigned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
