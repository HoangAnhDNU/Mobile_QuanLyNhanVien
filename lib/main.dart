import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/department_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/salary_provider.dart';
import 'providers/leave_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
      ],
      child: MaterialApp(
        title: 'Quản lý Nhân viên',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
