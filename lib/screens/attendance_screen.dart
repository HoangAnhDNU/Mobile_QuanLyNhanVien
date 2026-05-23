import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _records = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm công'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Chấm công'), Tab(text: 'Tổng hợp')],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAttendanceTab(), _buildSummaryTab()],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final empProvider = Provider.of<EmployeeProvider>(context);
    final attProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final activeEmployees = empProvider.employees.where((e) => e.status == 'Đang làm').toList();
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    // Pre-fill existing records
    final existing = attProvider.getByDate(dateStr);
    for (final r in existing) {
      _records.putIfAbsent(r.employeeId, () => r.status);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context, initialDate: _selectedDate,
                      firstDate: DateTime(2020), lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final records = activeEmployees.map((e) => attProvider.createRecord(
                    employeeId: e.id, employeeName: e.fullName,
                    date: dateStr, status: _records[e.id] ?? 'present',
                  )).toList();
                  attProvider.saveBatch(records);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu chấm công')));
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: activeEmployees.length,
            itemBuilder: (context, index) {
              final emp = activeEmployees[index];
              final status = _records[emp.id] ?? 'present';
              return ListTile(
                leading: CircleAvatar(child: Text(emp.fullName[0])),
                title: Text(emp.fullName),
                subtitle: Text(emp.employeeCode),
                trailing: DropdownButton<String>(
                  value: status,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('Đi làm')),
                    DropdownMenuItem(value: 'late', child: Text('Đi trễ')),
                    DropdownMenuItem(value: 'absent_approved', child: Text('Vắng CP')),
                    DropdownMenuItem(value: 'absent_unapproved', child: Text('Vắng KP')),
                  ],
                  onChanged: (v) => setState(() => _records[emp.id] = v ?? 'present'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab() {
    final empProvider = Provider.of<EmployeeProvider>(context);
    final attProvider = Provider.of<AttendanceProvider>(context);
    final activeEmps = empProvider.employees
        .where((e) => e.status == 'Đang làm')
        .map((e) => {'id': e.id, 'name': e.fullName})
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text('${_selectedDate.month}/${_selectedDate.year}'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context, initialDate: _selectedDate,
                      firstDate: DateTime(2020), lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  attProvider.loadSummary(_selectedDate.month, _selectedDate.year, activeEmps);
                },
                child: const Text('Xem'),
              ),
            ],
          ),
        ),
        Expanded(
          child: attProvider.summary.isEmpty
              ? const Center(child: Text('Chọn tháng và nhấn Xem'))
              : ListView.builder(
                  itemCount: attProvider.summary.length,
                  itemBuilder: (context, index) {
                    final s = attProvider.summary[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(s.employeeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Đi làm: ${s.presentDays} | Trễ: ${s.lateDays} | Vắng CP: ${s.absentApproved} | Vắng KP: ${s.absentUnapproved}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
