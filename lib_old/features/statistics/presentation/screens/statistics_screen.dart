import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../shared/widgets/app_drawer.dart';

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final employeeDao = EmployeeDao();
  final totalActive = await employeeDao.count(status: 'active');
  final totalResigned = await employeeDao.count(status: 'resigned');
  final newThisMonth = await employeeDao.countNewThisMonth();
  final byDepartment = await employeeDao.countByDepartment();
  final byGender = await employeeDao.countByGender();

  return StatisticsData(
    totalActive: totalActive,
    totalResigned: totalResigned,
    newThisMonth: newThisMonth,
    byDepartment: byDepartment,
    byGender: byGender,
  );
});

class StatisticsData {
  final int totalActive;
  final int totalResigned;
  final int newThisMonth;
  final List<Map<String, dynamic>> byDepartment;
  final Map<String, int> byGender;

  StatisticsData({
    required this.totalActive,
    required this.totalResigned,
    required this.newThisMonth,
    required this.byDepartment,
    required this.byGender,
  });
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      drawer: const AppDrawer(),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(statisticsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Đang làm',
                        value: '${data.totalActive}',
                        color: AppColors.success,
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Đã nghỉ',
                        value: '${data.totalResigned}',
                        color: Colors.grey,
                        icon: Icons.person_off,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Mới tháng này',
                        value: '${data.newThisMonth}',
                        color: AppColors.info,
                        icon: Icons.person_add,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingLG),

                // Pie chart - by department
                _buildSectionTitle(context, 'Nhân viên theo phòng ban'),
                const SizedBox(height: AppSizes.spacingMD),
                _buildDepartmentChart(context, data.byDepartment),
                const SizedBox(height: AppSizes.spacingLG),

                // Bar chart - by gender
                _buildSectionTitle(context, 'Nhân viên theo giới tính'),
                const SizedBox(height: AppSizes.spacingMD),
                _buildGenderChart(context, data.byGender),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDepartmentChart(BuildContext context, List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red, Colors.indigo];
    final total = data.fold<int>(0, (sum, item) => sum + ((item['count'] as int?) ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.asMap().entries.map((entry) {
                    final count = (entry.value['count'] as int?) ?? 0;
                    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: '$percentage%',
                      color: colors[entry.key % colors.length],
                      radius: 55,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: data.asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: colors[entry.key % colors.length]),
                    const SizedBox(width: 4),
                    Text('${entry.value['department_name']} (${entry.value['count']})',
                        style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChart(BuildContext context, Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));

    final maxValue = data.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue + 5,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ['Nam', 'Nữ', 'Khác'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(
                    toY: (data['male'] ?? 0).toDouble(),
                    color: Colors.blue,
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(
                    toY: (data['female'] ?? 0).toDouble(),
                    color: Colors.pink,
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(
                    toY: (data['other'] ?? 0).toDouble(),
                    color: Colors.grey,
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
