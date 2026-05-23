import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/models/leave_request_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/leave_provider.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveProvider.notifier).load(status: 'pending');
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final statuses = ['pending', 'approved', 'rejected'];
    ref.read(leaveProvider.notifier).load(status: statuses[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nghỉ phép'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã duyệt'),
            Tab(text: 'Từ chối'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.requests.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.event_note,
                  title: 'Không có đơn nghỉ phép',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.spacingMD),
                  itemCount: state.requests.length,
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                          child: Icon(
                            _getStatusIcon(request.status),
                            color: _getStatusColor(request.status),
                          ),
                        ),
                        title: Text(
                          request.employeeName ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${request.startDate} → ${request.endDate} (${request.totalDays} ngày)'),
                            if (request.reason != null) Text('Lý do: ${request.reason}'),
                          ],
                        ),
                        trailing: request.status == 'pending' &&
                                (authState.user?.isAdmin == true || authState.user?.isManager == true)
                            ? PopupMenuButton(
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'approve', child: Text('Duyệt')),
                                  const PopupMenuItem(
                                    value: 'reject',
                                    child: Text('Từ chối', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'approve') {
                                    ref.read(leaveProvider.notifier)
                                        .approve(request.id, authState.user!.id);
                                  } else {
                                    ref.read(leaveProvider.notifier)
                                        .reject(request.id, authState.user!.id);
                                  }
                                },
                              )
                            : null,
                        isThreeLine: request.reason != null,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final employeeDao = EmployeeDao();
    String? selectedEmployeeId;
    DateTime? startDate;
    DateTime? endDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo đơn nghỉ phép'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: employeeDao.getAll(status: 'active'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Nhân viên'),
                      items: snapshot.data!
                          .map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName)))
                          .toList(),
                      onChanged: (v) => selectedEmployeeId = v,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(startDate != null
                      ? 'Từ: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                      : 'Chọn ngày bắt đầu'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endDate != null
                      ? 'Đến: ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                      : 'Chọn ngày kết thúc'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setDialogState(() => endDate = d);
                  },
                ),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Lý do'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (selectedEmployeeId == null || startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final request = LeaveRequest(
                  id: const Uuid().v4(),
                  employeeId: selectedEmployeeId!,
                  startDate: startDate!.toIso8601String().split('T')[0],
                  endDate: endDate!.toIso8601String().split('T')[0],
                  reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                );
                ref.read(leaveProvider.notifier).create(request);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã tạo đơn nghỉ phép'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
