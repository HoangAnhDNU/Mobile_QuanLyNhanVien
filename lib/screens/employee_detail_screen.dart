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
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _buildInfoCard([
              _buildInfoRow(Icons.badge, 'Mã NV', employee.employeeCode),
              _buildInfoRow(Icons.business, 'Phòng ban', employee.department),
              _buildInfoRow(Icons.work, 'Chức vụ', employee.position),
              _buildInfoRow(Icons.circle, 'Trạng thái', employee.status),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow(Icons.cake, 'Ngày sinh', employee.dateOfBirth),
              _buildInfoRow(Icons.person, 'Giới tính', employee.gender),
              _buildInfoRow(Icons.phone, 'Điện thoại', employee.phone),
              _buildInfoRow(Icons.email, 'Email', employee.email),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow(Icons.calendar_today, 'Ngày vào', employee.startDate),
              _buildInfoRow(Icons.attach_money, 'Lương cơ bản',
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
