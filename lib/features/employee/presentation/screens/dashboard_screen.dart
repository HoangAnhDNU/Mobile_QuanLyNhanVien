import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../core/database/daos/attendance_dao.dart';
import '../../../../shared/widgets/app_drawer.dart';

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final employeeDao = EmployeeDao();
  final attendanceDao = AttendanceDao();

  final totalEmployees = await employeeDao.count(status: 'active');
  final newThisMonth = await employeeDao.countNewThisMonth();
  final onLeaveToday = await attendanceDao.countOnLeaveToday();
  final departmentStats = await employeeDao.countByDepartment();

  return DashboardData(
    totalEmployees: totalEmployees,
    newThisMonth: newThisMonth,
    onLeaveToday: onLeaveToday,
    departmentStats: departmentStats,
  );
});

class DashboardData {
  final int totalEmployees;
  final int newThisMonth;
  final int onLeaveToday;
  final List<Map<String, dynamic>> departmentStats;

  DashboardData({
    required this.totalEmployees,
    required this.newThisMonth,
    required this.onLeaveToday,
    required this.departmentStats,
  });
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardDataProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards
                _buildStatCards(context, data),
                const SizedBox(height: AppSizes.spacingLG),

                // Chart
                Text(
                  'Nhân viên theo phòng ban',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingMD),
                _buildPieChart(context, data.departmentStats),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Tổng nhân viên',
          value: '${data.totalEmployees}',
          icon: Icons.people,
          color: AppColors.primaryLight,
        ),
        _StatCard(
          title: 'NV mới tháng này',
          value: '${data.newThisMonth}',
          icon: Icons.person_add,
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Nghỉ phép hôm nay',
          value: '${data.onLeaveToday}',
          icon: Icons.event_busy,
          color: AppColors.warning,
        ),
        _StatCard(
          title: 'Phòng ban',
          value: '${data.departmentStats.length}',
          icon: Icons.business,
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, List<Map<String, dynamic>> stats) {
    if (stats.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Chưa có dữ liệu')),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];

    final sections = stats.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final count = (item['count'] as int?) ?? 0;
      final name = item['department_name'] as String? ?? 'N/A';
      return PieChartSectionData(
        value: count.toDouble(),
        title: '$count',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['department_name']} (${item['count']})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
