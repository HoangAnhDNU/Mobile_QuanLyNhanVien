import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../theme/app_colors.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Đang làm':
        return AppColors.success;
      case 'Nghỉ phép':
        return AppColors.accent;
      case 'Đã nghỉ':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  employee.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.employeeCode} • ${employee.department}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(employee.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(employee.status)),
                ),
                child: Text(
                  employee.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(employee.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
