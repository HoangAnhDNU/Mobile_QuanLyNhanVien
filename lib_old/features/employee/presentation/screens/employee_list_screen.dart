import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/employee_provider.dart';
import '../../../department/presentation/providers/department_provider.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeListProvider.notifier).loadEmployees();
      ref.read(departmentListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeListProvider);
    final departments = ref.watch(departmentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhân viên')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingMD),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc mã NV...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(employeeListProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(employeeListProvider.notifier).search(value);
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMD),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: state.statusFilter == null,
                  onSelected: (_) {
                    ref.read(employeeListProvider.notifier).filterByStatus(null);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Đang làm'),
                  selected: state.statusFilter == 'active',
                  onSelected: (_) {
                    ref.read(employeeListProvider.notifier).filterByStatus('active');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Nghỉ phép'),
                  selected: state.statusFilter == 'on_leave',
                  onSelected: (_) {
                    ref.read(employeeListProvider.notifier).filterByStatus('on_leave');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Đã nghỉ'),
                  selected: state.statusFilter == 'resigned',
                  onSelected: (_) {
                    ref.read(employeeListProvider.notifier).filterByStatus('resigned');
                  },
                ),
                const SizedBox(width: 8),
                // Department filter
                departments.when(
                  data: (depts) => PopupMenuButton<String?>(
                    child: Chip(
                      label: Text(state.departmentFilter != null ? 'Phòng ban ✓' : 'Phòng ban'),
                      avatar: const Icon(Icons.filter_list, size: 18),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('Tất cả phòng ban')),
                      ...depts.map((d) => PopupMenuItem(value: d.id, child: Text(d.name))),
                    ],
                    onSelected: (value) {
                      ref.read(employeeListProvider.notifier).filterByDepartment(value);
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Employee list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.employees.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'Chưa có nhân viên',
                        subtitle: 'Nhấn + để thêm nhân viên mới',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(employeeListProvider.notifier).loadEmployees();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMD),
                          itemCount: state.employees.length,
                          itemBuilder: (context, index) {
                            final employee = state.employees[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(
                                    employee.fullName.isNotEmpty
                                        ? employee.fullName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  employee.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${employee.employeeCode} • ${employee.departmentName ?? "Chưa xếp phòng"}',
                                ),
                                trailing: _buildStatusBadge(employee.status),
                                onTap: () => context.push('/employees/${employee.id}'),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/employees/form/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = AppColors.statusActive;
        break;
      case 'on_leave':
        color = AppColors.statusOnLeave;
        break;
      case 'resigned':
        color = AppColors.statusResigned;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        Formatters.employeeStatusDisplay(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
