import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/salary_provider.dart';

class SalaryScreen extends ConsumerStatefulWidget {
  const SalaryScreen({super.key});

  @override
  ConsumerState<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends ConsumerState<SalaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(salaryProvider.notifier).loadSalaries(now.month, now.year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bảng lương')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Tháng ${state.selectedMonth}/${state.selectedYear}'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(state.selectedYear, state.selectedMonth),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        ref.read(salaryProvider.notifier).loadSalaries(date.month, date.year);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Tính lương'),
                  onPressed: state.isLoading
                      ? null
                      : () => ref.read(salaryProvider.notifier).calculateSalaries(),
                ),
              ],
            ),
          ),

          // Salary list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.salaries.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.attach_money,
                        title: 'Chưa có dữ liệu lương',
                        subtitle: 'Nhấn "Tính lương" để tính lương tháng này',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMD),
                        itemCount: state.salaries.length,
                        itemBuilder: (context, index) {
                          final salary = state.salaries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  (salary.employeeName ?? '?')[0],
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              title: Text(
                                salary.employeeName ?? 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Thực nhận: ${Formatters.currency(salary.netSalary)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _buildSalaryRow('Ngày công', '${salary.workDays} ngày'),
                                      _buildSalaryRow('Lương cơ bản', Formatters.currency(salary.baseSalary)),
                                      _buildSalaryRow('Phụ cấp', Formatters.currency(salary.allowance)),
                                      _buildSalaryRow('Khấu trừ', '-${Formatters.currency(salary.deduction)}',
                                          isDeduction: true),
                                      const Divider(),
                                      _buildSalaryRow('THỰC NHẬN', Formatters.currency(salary.netSalary),
                                          isBold: true),
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
      ),
    );
  }

  Widget _buildSalaryRow(String label, String value,
      {bool isDeduction = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDeduction ? Colors.red : (isBold ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }
}
