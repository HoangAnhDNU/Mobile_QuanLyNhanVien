import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nghỉ phép'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Chờ duyệt'), Tab(text: 'Đã duyệt'), Tab(text: 'Từ chối')],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('pending'),
          _buildList('approved'),
          _buildList('rejected'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(String status) {
    return Consumer<LeaveProvider>(
      builder: (context, provider, _) {
        final requests = provider.getByStatus(status);
        if (requests.isEmpty) return const Center(child: Text('Không có đơn nào'));

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final canApprove = authProvider.user?.isAdmin == true || authProvider.user?.isManager == true;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(r.status).withOpacity(0.2),
                  child: Icon(_statusIcon(r.status), color: _statusColor(r.status)),
                ),
                title: Text(r.employeeName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.startDate} → ${r.endDate} (${r.totalDays} ngày)'),
                    if (r.reason != null) Text('Lý do: ${r.reason}'),
                  ],
                ),
                isThreeLine: r.reason != null,
                trailing: status == 'pending' && canApprove
                    ? PopupMenuButton(
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'approve', child: Text('Duyệt')),
                          const PopupMenuItem(value: 'reject', child: Text('Từ chối', style: TextStyle(color: Colors.red))),
                        ],
                        onSelected: (value) {
                          if (value == 'approve') provider.approve(r.id);
                          if (value == 'reject') provider.reject(r.id);
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo đơn nghỉ phép'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nhân viên')),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(startDate != null ? 'Từ: ${startDate!.day}/${startDate!.month}/${startDate!.year}' : 'Chọn ngày bắt đầu'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endDate != null ? 'Đến: ${endDate!.day}/${endDate!.month}/${endDate!.year}' : 'Chọn ngày kết thúc'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: startDate ?? DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setDialogState(() => endDate = d);
                  },
                ),
                TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Lý do'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || startDate == null || endDate == null) return;
                Provider.of<LeaveProvider>(context, listen: false).create(LeaveRequest(
                  id: '',
                  employeeId: 'new',
                  employeeName: nameCtrl.text,
                  startDate: '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                  endDate: '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
                  reason: reasonCtrl.text.isNotEmpty ? reasonCtrl.text : null,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}
