import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';
import '../theme/app_colors.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _startDateController;
  late TextEditingController _salaryController;

  String _gender = 'Nam';
  String _department = 'Phòng Kỹ thuật';
  String _position = 'Nhân viên';
  String _status = 'Đang làm';

  bool get isEditing => widget.employee != null;

  final List<String> _departments = [
    'Phòng Kỹ thuật',
    'Phòng Nhân sự',
    'Phòng Kinh doanh',
    'Phòng Tài chính',
    'Phòng Marketing',
  ];

  final List<String> _positions = [
    'Giám đốc',
    'Trưởng phòng',
    'Phó phòng',
    'Nhóm trưởng',
    'Nhân viên',
    'Thực tập sinh',
  ];

  final List<String> _statuses = ['Đang làm', 'Nghỉ phép', 'Đã nghỉ'];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _codeController = TextEditingController(text: e?.employeeCode ?? '');
    _nameController = TextEditingController(text: e?.fullName ?? '');
    _dobController = TextEditingController(text: e?.dateOfBirth ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _startDateController = TextEditingController(text: e?.startDate ?? '');
    _salaryController = TextEditingController(
      text: e != null ? e.baseSalary.toStringAsFixed(0) : '',
    );
    if (e != null) {
      _gender = e.gender;
      _department = e.department;
      _position = e.position;
      _status = e.status;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _startDateController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<EmployeeProvider>(context, listen: false);

    final employee = Employee(
      id: widget.employee?.id ?? '',
      employeeCode: _codeController.text.trim(),
      fullName: _nameController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _gender,
      department: _department,
      position: _position,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      startDate: _startDateController.text.trim(),
      baseSalary: double.tryParse(_salaryController.text.trim()) ?? 0,
      status: _status,
    );

    if (isEditing) {
      provider.updateEmployee(employee);
    } else {
      provider.addEmployee(employee);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Đã cập nhật nhân viên' : 'Đã thêm nhân viên mới'),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa nhân viên' : 'Thêm nhân viên'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_codeController, 'Mã nhân viên', Icons.badge),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Họ và tên', Icons.person),
              const SizedBox(height: 12),
              _buildDateField(_dobController, 'Ngày sinh'),
              const SizedBox(height: 12),
              _buildDropdown('Giới tính', _gender, ['Nam', 'Nữ'], (val) {
                setState(() => _gender = val!);
              }),
              const SizedBox(height: 12),
              _buildDropdown('Phòng ban', _department, _departments, (val) {
                setState(() => _department = val!);
              }),
              const SizedBox(height: 12),
              _buildDropdown('Chức vụ', _position, _positions, (val) {
                setState(() => _position = val!);
              }),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildDateField(_startDateController, 'Ngày vào làm'),
              const SizedBox(height: 12),
              _buildTextField(_salaryController, 'Lương cơ bản (VNĐ)', Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildDropdown('Trạng thái', _status, _statuses, (val) {
                setState(() => _status = val!);
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Cập nhật' : 'Thêm nhân viên',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(controller),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
