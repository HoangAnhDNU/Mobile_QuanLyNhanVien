import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/daos/employee_dao.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/employee_model.dart';
import '../providers/employee_provider.dart';
import '../../../department/presentation/providers/department_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final String? employeeId;

  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dao = EmployeeDao();
  final _uuid = const Uuid();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _salaryController;

  String? _gender;
  String? _departmentId;
  String? _positionId;
  String? _contractType;
  String _status = 'active';
  DateTime? _dateOfBirth;
  DateTime? _startDate;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _salaryController = TextEditingController();

    if (widget.employeeId != null) {
      _isEditing = true;
      _loadEmployee();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentListProvider.notifier).load();
    });
  }

  Future<void> _loadEmployee() async {
    final employee = await _dao.getById(widget.employeeId!);
    if (employee != null && mounted) {
      setState(() {
        _codeController.text = employee.employeeCode;
        _nameController.text = employee.fullName;
        _phoneController.text = employee.phone ?? '';
        _emailController.text = employee.email ?? '';
        _salaryController.text = employee.baseSalary.toInt().toString();
        _gender = employee.gender;
        _departmentId = employee.departmentId;
        _positionId = employee.positionId;
        _contractType = employee.contractType;
        _status = employee.status;
        _dateOfBirth = employee.dateOfBirth != null ? DateTime.tryParse(employee.dateOfBirth!) : null;
        _startDate = employee.startDate != null ? DateTime.tryParse(employee.startDate!) : null;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Check duplicate code
    final codeExists = await _dao.isCodeExists(
      _codeController.text.trim(),
      _isEditing ? widget.employeeId : null,
    );
    if (codeExists && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã nhân viên đã tồn tại'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final employee = Employee(
      id: _isEditing ? widget.employeeId! : _uuid.v4(),
      employeeCode: _codeController.text.trim(),
      fullName: _nameController.text.trim(),
      dateOfBirth: _dateOfBirth?.toIso8601String().split('T')[0],
      gender: _gender,
      departmentId: _departmentId,
      positionId: _positionId,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      startDate: _startDate?.toIso8601String().split('T')[0],
      contractType: _contractType,
      baseSalary: double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0,
      status: _status,
    );

    try {
      if (_isEditing) {
        await _dao.update(employee);
      } else {
        await _dao.insert(employee);
      }

      if (mounted) {
        ref.read(employeeListProvider.notifier).loadEmployees();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Cập nhật thành công' : 'Thêm nhân viên thành công'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentListProvider);
    final positions = ref.watch(positionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa nhân viên' : 'Thêm nhân viên'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Employee code
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Mã nhân viên *'),
                validator: Validators.employeeCode,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Full name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên *'),
                validator: (v) => Validators.minLength(v, 2, 'Họ tên'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Giới tính'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Nam')),
                  DropdownMenuItem(value: 'female', child: Text('Nữ')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Date of birth
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dateOfBirth != null
                      ? 'Ngày sinh: ${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Chọn ngày sinh',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth ?? DateTime(1990),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _dateOfBirth = date);
                },
              ),
              const Divider(),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => v != null && v.isNotEmpty ? Validators.phone(v) : null,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.isNotEmpty ? Validators.email(v) : null,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Department
              departments.when(
                data: (depts) => DropdownButtonFormField<String>(
                  value: _departmentId,
                  decoration: const InputDecoration(labelText: 'Phòng ban'),
                  items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                  onChanged: (v) => setState(() => _departmentId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Lỗi tải phòng ban'),
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Position
              positions.when(
                data: (pos) => DropdownButtonFormField<String>(
                  value: _positionId,
                  decoration: const InputDecoration(labelText: 'Chức vụ'),
                  items: pos.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _positionId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Lỗi tải chức vụ'),
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Contract type
              DropdownButtonFormField<String>(
                value: _contractType,
                decoration: const InputDecoration(labelText: 'Loại hợp đồng'),
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('Toàn thời gian')),
                  DropdownMenuItem(value: 'part_time', child: Text('Bán thời gian')),
                  DropdownMenuItem(value: 'intern', child: Text('Thực tập')),
                  DropdownMenuItem(value: 'contractor', child: Text('Hợp đồng')),
                ],
                onChanged: (v) => setState(() => _contractType = v),
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Start date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startDate != null
                      ? 'Ngày vào làm: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Chọn ngày vào làm',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _startDate = date);
                },
              ),
              const Divider(),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Lương cơ bản (VNĐ) *'),
                keyboardType: TextInputType.number,
                validator: Validators.salary,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              // Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Đang làm việc')),
                  DropdownMenuItem(value: 'on_leave', child: Text('Nghỉ phép')),
                  DropdownMenuItem(value: 'resigned', child: Text('Đã nghỉ việc')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'active'),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // Save button
              SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : Text(_isEditing ? 'Cập nhật' : 'Lưu nhân viên'),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMD),
            ],
          ),
        ),
      ),
    );
  }
}
