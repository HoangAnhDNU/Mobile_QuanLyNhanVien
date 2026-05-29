import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/employee_list_screen.dart';
import '../screens/department_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/salary_screen.dart';
import '../screens/leave_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/login_screen.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Người dùng',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getRoleDisplay(user?.role),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _item(context, Icons.dashboard, 'Dashboard', const DashboardScreen()),
          _item(context, Icons.people, 'Nhân viên', const EmployeeListScreen()),
          _item(context, Icons.business, 'Phòng ban', const DepartmentScreen()),
          _item(context, Icons.access_time, 'Chấm công', const AttendanceScreen()),
          _item(context, Icons.attach_money, 'Bảng lương', const SalaryScreen()),
          _item(context, Icons.event_note, 'Nghỉ phép', const LeaveScreen()),
          _item(context, Icons.bar_chart, 'Thống kê', const StatisticsScreen()),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.isDarkMode ? Colors.amber : Colors.orange,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(themeProvider.isDarkMode ? 'Đang bật' : 'Đang tắt'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin': return 'Quản trị viên';
      case 'manager': return 'Quản lý';
      default: return 'Nhân viên';
    }
  }
}
