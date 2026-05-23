import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/employee_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      drawer: const AppDrawer(),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final employees = provider.employees;
          final active = employees.where((e) => e.status == 'Đang làm').length;
          final resigned = employees.where((e) => e.status == 'Đã nghỉ').length;

          final deptCounts = <String, int>{};
          final genderCounts = <String, int>{};
          for (final e in employees.where((e) => e.status == 'Đang làm')) {
            deptCounts[e.department] = (deptCounts[e.department] ?? 0) + 1;
            genderCounts[e.gender] = (genderCounts[e.gender] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SummaryCard(title: 'Đang làm', value: '$active', color: AppColors.success, icon: Icons.people),
                    const SizedBox(width: 12),
                    _SummaryCard(title: 'Đã nghỉ', value: '$resigned', color: Colors.grey, icon: Icons.person_off),
                    const SizedBox(width: 12),
                    _SummaryCard(title: 'Tổng', value: '${employees.length}', color: AppColors.primary, icon: Icons.person_add),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Nhân viên theo phòng ban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDeptChart(context, deptCounts),
                const SizedBox(height: 24),
                const Text('Nhân viên theo giới tính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildGenderChart(genderCounts),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeptChart(BuildContext context, Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red];
    final entries = data.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final pct = total > 0 ? (e.value.value / total * 100).toStringAsFixed(1) : '0';
                  return PieChartSectionData(
                    value: e.value.value.toDouble(), title: '$pct%',
                    color: colors[e.key % colors.length], radius: 55,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                centerSpaceRadius: 35, sectionsSpace: 2,
              )),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 8,
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
        ),
      ),
    );
  }

  Widget _buildGenderChart(Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal + 3,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                final labels = ['Nam', 'Nữ'];
                final idx = v.toInt();
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(idx < labels.length ? labels[idx] : '', style: const TextStyle(fontSize: 12)));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (data['Nam'] ?? 0).toDouble(), color: Colors.blue, width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (data['Nữ'] ?? 0).toDouble(), color: Colors.pink, width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]),
            ],
          )),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
