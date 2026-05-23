class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Employees
  static const String employees = '/employees';
  static String employeeById(String id) => '/employees/$id';

  // Departments
  static const String departments = '/departments';
  static String departmentById(String id) => '/departments/$id';

  // Positions
  static const String positions = '/positions';
  static String positionById(String id) => '/positions/$id';

  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceSummary = '/attendance/summary';

  // Salaries
  static const String salaries = '/salaries';
  static const String salariesCalculate = '/salaries/calculate';

  // Leave Requests
  static const String leaves = '/leaves';
  static String leaveById(String id) => '/leaves/$id';
  static String approveLeave(String id) => '/leaves/$id/approve';
  static String rejectLeave(String id) => '/leaves/$id/reject';
}
