import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/salary_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng lương'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      drawer: const AppDrawer(),
      body: Consumer<SalaryProvider>(
        builder: (context, salaryProvider, _) {
          final salaries = salaryProvider.salaries;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: Text('Tháng ${salaryProvider.selectedMonth}/${salaryProvider.selectedYear}'),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(salaryProvider.selectedYear, salaryProvider.selectedMonth),
                            firstDate: DateTime(2020), lastDate: DateTime.now(),
                          );
                          if (date != null) salaryProvider.setMonth(date.month, date.year);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calculate),
                      label: const Text('Tính lương'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () {
                        final emps = Provider.of<EmployeeProvider>(context, listen: false).employees;
                        final att = Provider.of<AttendanceProvider>(context, listen: false);
                        salaryProvider.calculateSalaries(emps, att);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: salaries.isEmpty
                    ? const Center(child: Text('Nhấn "Tính lương" để tính'))
                    : ListView.builder(
                        itemCount: salaries.length,
                        itemBuilder: (context, index) {
                          final s = salaries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text((s.employeeName ?? '?')[0], style: const TextStyle(color: AppColors.primary)),
                              ),
                              title: Text(s.employeeName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Thực nhận: ${_formatCurrency(s.netSalary)} đ', style: const TextStyle(color: AppColors.primary)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _row('Ngày công', '${s.workDays} ngày'),
                                      _row('Lương cơ bản', '${_formatCurrency(s.baseSalary)} đ'),
                                      _row('Phụ cấp', '${_formatCurrency(s.allowance)} đ'),
                                      const Divider(),
                                      _row('THỰC NHẬN', '${_formatCurrency(s.netSalary)} đ', bold: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: bold ? Colors.green : null)),
        ],
      ),
    );
  }
}
