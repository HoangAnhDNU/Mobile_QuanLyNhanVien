class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'Trường này']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Trường này']) {
    if (value == null || value.trim().length < min) {
      return '$fieldName phải có ít nhất $min ký tự';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final phoneRegex = RegExp(r'^0\d{9,10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'SĐT phải bắt đầu bằng 0 và có 10-11 số';
    }
    return null;
  }

  static String? salary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lương không được để trống';
    }
    final salary = double.tryParse(value.replaceAll(',', ''));
    if (salary == null || salary < 0) {
      return 'Lương phải là số không âm';
    }
    return null;
  }

  static String? employeeCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mã nhân viên không được để trống';
    }
    final codeRegex = RegExp(r'^NV\d{3,}$');
    if (!codeRegex.hasMatch(value.trim())) {
      return 'Mã NV phải theo định dạng NVxxx (ví dụ: NV001)';
    }
    return null;
  }
}
