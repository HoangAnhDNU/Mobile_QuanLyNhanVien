import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/employee/presentation/screens/dashboard_screen.dart';
import '../../features/employee/presentation/screens/employee_list_screen.dart';
import '../../features/employee/presentation/screens/employee_detail_screen.dart';
import '../../features/employee/presentation/screens/employee_form_screen.dart';
import '../../features/department/presentation/screens/department_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/salary/presentation/screens/salary_screen.dart';
import '../../features/leave/presentation/screens/leave_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/employees',
        builder: (context, state) => const EmployeeListScreen(),
      ),
      GoRoute(
        path: '/employees/:id',
        builder: (context, state) => EmployeeDetailScreen(
          employeeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/employees/form/new',
        builder: (context, state) => const EmployeeFormScreen(),
      ),
      GoRoute(
        path: '/employees/form/:id',
        builder: (context, state) => EmployeeFormScreen(
          employeeId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/departments',
        builder: (context, state) => const DepartmentScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/salary',
        builder: (context, state) => const SalaryScreen(),
      ),
      GoRoute(
        path: '/leaves',
        builder: (context, state) => const LeaveScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Trang không tồn tại: ${state.error}'),
      ),
    ),
  );
});
