import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Người dùng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getRoleDisplay(user?.role),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Nhân viên',
            route: '/employees',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.business,
            title: 'Phòng ban',
            route: '/departments',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.access_time,
            title: 'Chấm công',
            route: '/attendance',
          ),
          if (user?.isAdmin == true || user?.isManager == true)
            _buildDrawerItem(
              context,
              icon: Icons.attach_money,
              title: 'Bảng lương',
              route: '/salary',
            ),
          _buildDrawerItem(
            context,
            icon: Icons.event_note,
            title: 'Nghỉ phép',
            route: '/leaves',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart,
            title: 'Thống kê',
            route: '/statistics',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                      child: const Text('Đăng xuất',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = GoRouterState.of(context).matchedLocation == route;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          )),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'manager':
        return 'Quản lý';
      case 'employee':
        return 'Nhân viên';
      default:
        return '';
    }
  }
}
