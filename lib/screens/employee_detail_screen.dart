import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../theme/app_colors.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    final employee = Provider.of<EmployeeProvider>(context).getById(employeeId);

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết')),
        body: const Center(child: Text('Không tìm thấy nhân viên')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeFormScreen(employee: employee),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                employee.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              employee.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              employee.position,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildInfoCard([
              _buildInfoRow(context, Icons.badge, 'Mã NV', employee.employeeCode),
              _buildInfoRow(context, Icons.business, 'Phòng ban', employee.department),
              _buildInfoRow(context, Icons.work, 'Chức vụ', employee.position),
              _buildInfoRow(context, Icons.circle, 'Trạng thái', employee.status),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow(context, Icons.cake, 'Ngày sinh', employee.dateOfBirth),
              _buildInfoRow(context, Icons.person, 'Giới tính', employee.gender),
              _buildInfoRow(context, Icons.phone, 'Điện thoại', employee.phone),
              _buildInfoRow(context, Icons.email, 'Email', employee.email),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow(context, Icons.calendar_today, 'Ngày vào', employee.startDate),
              _buildInfoRow(context, Icons.attach_money, 'Lương cơ bản',
                  '${_formatCurrency(employee.baseSalary)} đ'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
