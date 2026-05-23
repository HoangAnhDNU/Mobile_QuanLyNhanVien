import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../data/models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final _uuid = const Uuid();
  final _employeeDao = EmployeeDao();
  final Map<String, String> _attendanceRecords = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    ref.read(attendanceProvider.notifier).loadByDate(dateStr);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm công'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chấm công'),
            Tab(text: 'Tổng hợp'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttendanceTab(context, state),
          _buildSummaryTab(context, state),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(BuildContext context, AttendanceState state) {
    return Column(
      children: [
        // Date picker
        Padding(
          padding: const EdgeInsets.all(AppSizes.spacingMD),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveAttendance,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),

        // Employee list with attendance status
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder(
                  future: _employeeDao.getAll(status: 'active'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final employees = snapshot.data!;

                    // Pre-fill existing records
                    for (final record in state.records) {
                      _attendanceRecords[record.employeeId] = record.status;
                    }

                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        final currentStatus = _attendanceRecords[emp.id] ?? 'present';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(currentStatus).withOpacity(0.2),
                            child: Text(emp.fullName[0]),
                          ),
                          title: Text(emp.fullName),
                          subtitle: Text(emp.employeeCode),
                          trailing: DropdownButton<String>(
                            value: currentStatus,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'present', child: Text('Đi làm')),
                              DropdownMenuItem(value: 'late', child: Text('Đi trễ')),
                              DropdownMenuItem(value: 'absent_approved', child: Text('Vắng CP')),
                              DropdownMenuItem(value: 'absent_unapproved', child: Text('Vắng KP')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _attendanceRecords[emp.id] = value ?? 'present';
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab(BuildContext context, AttendanceState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.spacingMD),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text('${_selectedDate.month}/${_selectedDate.year}'),
                  onPressed: () async {
                    // Simple month picker
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      ref.read(attendanceProvider.notifier)
                          .loadSummary(date.month, date.year);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(attendanceProvider.notifier)
                      .loadSummary(_selectedDate.month, _selectedDate.year);
                },
                child: const Text('Xem'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.summary.isEmpty
              ? const Center(child: Text('Chọn tháng và nhấn Xem'))
              : ListView.builder(
                  itemCount: state.summary.length,
                  itemBuilder: (context, index) {
                    final s = state.summary[index];
                    final isWarning = s.absentUnapproved >= 5;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isWarning ? Colors.red.shade50 : null,
                      child: ListTile(
                        title: Text(
                          s.employeeName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isWarning ? Colors.red : null,
                          ),
                        ),
                        subtitle: Text(
                          'Đi làm: ${s.presentDays} | Trễ: ${s.lateDays} | Vắng CP: ${s.absentApproved} | Vắng KP: ${s.absentUnapproved}',
                        ),
                        trailing: isWarning
                            ? const Icon(Icons.warning, color: Colors.red)
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _saveAttendance() async {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    final records = _attendanceRecords.entries.map((e) {
      return Attendance(
        id: _uuid.v4(),
        employeeId: e.key,
        date: dateStr,
        status: e.value,
        checkInTime: e.value == 'present' ? '08:00:00' : (e.value == 'late' ? '08:30:00' : null),
        checkOutTime: (e.value == 'present' || e.value == 'late') ? '17:30:00' : null,
      );
    }).toList();

    await ref.read(attendanceProvider.notifier).saveBatch(records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu chấm công'), backgroundColor: Colors.green),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.statusPresent;
      case 'late':
        return AppColors.statusLate;
      case 'absent_approved':
        return AppColors.statusAbsentApproved;
      case 'absent_unapproved':
        return AppColors.statusAbsentUnapproved;
      default:
        return Colors.grey;
    }
  }
}
