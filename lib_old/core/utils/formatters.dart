import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  static String currency(double amount) {
    return '${_currencyFormat.format(amount)} đ';
  }

  static String currencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return _currencyFormat.format(amount);
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String workDays(int days) {
    return '$days ngày';
  }

  static String genderDisplay(String gender) {
    switch (gender) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  static String contractTypeDisplay(String type) {
    switch (type) {
      case 'full_time':
        return 'Toàn thời gian';
      case 'part_time':
        return 'Bán thời gian';
      case 'intern':
        return 'Thực tập';
      case 'contractor':
        return 'Hợp đồng';
      default:
        return type;
    }
  }

  static String employeeStatusDisplay(String status) {
    switch (status) {
      case 'active':
        return 'Đang làm việc';
      case 'on_leave':
        return 'Nghỉ phép';
      case 'resigned':
        return 'Đã nghỉ việc';
      default:
        return status;
    }
  }

  static String attendanceStatusDisplay(String status) {
    switch (status) {
      case 'present':
        return 'Đi làm';
      case 'absent_approved':
        return 'Vắng có phép';
      case 'absent_unapproved':
        return 'Vắng không phép';
      case 'late':
        return 'Đi trễ';
      default:
        return status;
    }
  }

  static String leaveStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  static String roleDisplay(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'manager':
        return 'Quản lý';
      case 'employee':
        return 'Nhân viên';
      default:
        return role;
    }
  }
}
