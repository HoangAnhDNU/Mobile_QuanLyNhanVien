import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/employee_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Consumer<EmployeeProvider>(
        builder: (context, empProvider, _) {
          final employees = empProvider.employees;
          final active = employees.where((e) => e.status == 'Đang làm').length;
          final onLeave = employees.where((e) => e.status == 'Nghỉ phép').length;
          final deptCounts = <String, int>{};
          for (final e in employees.where((e) => e.status == 'Đang làm')) {
            deptCounts[e.department] = (deptCounts[e.department] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(title: 'Tổng nhân viên', value: '${employees.length}', icon: Icons.people, color: AppColors.primary),
                    _StatCard(title: 'Đang làm', value: '$active', icon: Icons.check_circle, color: AppColors.success),
                    _StatCard(title: 'Nghỉ phép', value: '$onLeave', icon: Icons.event_busy, color: Colors.orange),
                    _StatCard(title: 'Phòng ban', value: '${deptCounts.length}', icon: Icons.business, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Nhân viên theo phòng ban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPieChart(context, deptCounts),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, int> deptCounts) {
    if (deptCounts.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red];
    final entries = deptCounts.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(PieChartData(
            sections: entries.asMap().entries.map((e) {
              final pct = total > 0 ? (e.value.value / total * 100).toStringAsFixed(1) : '0';
              return PieChartSectionData(
                value: e.value.value.toDouble(),
                title: '$pct%',
                color: colors[e.key % colors.length],
                radius: 55,
                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList(),
            centerSpaceRadius: 35,
            sectionsSpace: 2,
          )),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: entries.asMap().entries.map((e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: colors[e.key % colors.length]),
              const SizedBox(width: 4),
              Text('${e.value.key} (${e.value.value})', style: const TextStyle(fontSize: 12)),
            ],
          )).toList(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
