# CHI TIẾT KỸ THUẬT DỰ ÁN QUẢN LÝ NHÂN VIÊN

---

## 1. Thiết kế Giao diện (UI/UX)

Tài liệu hiện tại đã có danh sách 11 màn hình đề xuất (Đăng nhập, Dashboard, Danh sách nhân viên, v.v.), nhưng cần bản thiết kế chi tiết hơn.

### 1.1. Wireframe/Mockup

- **Công cụ đề xuất:** Figma hoặc Adobe XD
- **Yêu cầu:** Bản thiết kế trực quan cho từng màn hình, xác định rõ:
  - Vị trí đặt các nút bấm, icon hành động
  - Vị trí và kiểu biểu đồ (sử dụng `fl_chart`)
  - Layout form nhập liệu (spacing, alignment)
  - Luồng điều hướng giữa các màn hình (navigation flow)

#### Danh sách wireframe cần thiết kế:

| # | Màn hình | Thành phần chính |
|---|----------|-----------------|
| 1 | Đăng nhập | TextField username, password, nút đăng nhập, logo |
| 2 | Dashboard | StatCard x4, PieChart phòng ban, Drawer menu |
| 3 | Danh sách nhân viên | SearchBar, FilterChips, ListView, FAB thêm mới |
| 4 | Chi tiết nhân viên | Avatar, thông tin cá nhân, tabs (hồ sơ/chấm công/lương) |
| 5 | Form thêm/sửa NV | TextFields, DatePickers, Dropdowns, nút Lưu/Hủy |
| 6 | Quản lý phòng ban | ListView phòng ban, dialog thêm/sửa, badge số NV |
| 7 | Chấm công | DatePicker, danh sách NV + checkbox trạng thái |
| 8 | Bảng lương tháng | MonthPicker, DataTable lương, nút tính lương |
| 9 | Quản lý nghỉ phép | TabBar (chờ duyệt/đã duyệt/từ chối), FAB tạo đơn |
| 10 | Báo cáo thống kê | PieChart, BarChart, summary cards |
| 11 | Cài đặt tài khoản | Avatar, thông tin user, nút đổi mật khẩu, toggle dark mode |

### 1.2. Design System

#### Bảng màu chủ đạo (Material Design 3)

```dart
// Light Theme
static const Color primaryColor = Color(0xFF1565C0);      // Blue 800
static const Color primaryContainer = Color(0xFFD1E4FF);  // Blue 100
static const Color secondaryColor = Color(0xFF546E7A);    // Blue Grey 600
static const Color surfaceColor = Color(0xFFFAFAFA);      // Grey 50
static const Color errorColor = Color(0xFFD32F2F);        // Red 700
static const Color successColor = Color(0xFF388E3C);      // Green 700
static const Color warningColor = Color(0xFFF57C00);      // Orange 700

// Dark Theme
static const Color primaryColorDark = Color(0xFF90CAF9);  // Blue 200
static const Color surfaceColorDark = Color(0xFF121212);  // Material Dark
```

#### Typography

```dart
// Font chính: Google Fonts - Roboto (mặc định Material) hoặc Inter
// Hierarchy:
// - Headline Large: 28sp, Bold   → Tiêu đề màn hình
// - Headline Medium: 24sp, Bold  → Section headers
// - Title Large: 20sp, SemiBold  → Card titles
// - Title Medium: 16sp, SemiBold → List item titles
// - Body Large: 16sp, Regular    → Nội dung chính
// - Body Medium: 14sp, Regular   → Nội dung phụ
// - Label Large: 14sp, Medium    → Button text
// - Label Small: 11sp, Medium    → Caption, tags
```

#### Spacing & Sizing

```dart
// Padding/Margin chuẩn (8dp grid system)
static const double spacingXS = 4.0;
static const double spacingSM = 8.0;
static const double spacingMD = 16.0;
static const double spacingLG = 24.0;
static const double spacingXL = 32.0;
static const double spacingXXL = 48.0;

// Border Radius
static const double radiusSM = 8.0;
static const double radiusMD = 12.0;
static const double radiusLG = 16.0;
static const double radiusFull = 999.0;  // Circular

// Icon sizes
static const double iconSM = 16.0;
static const double iconMD = 24.0;
static const double iconLG = 32.0;

// Avatar sizes
static const double avatarSM = 32.0;
static const double avatarMD = 48.0;
static const double avatarLG = 72.0;
static const double avatarXL = 120.0;  // Profile screen
```

### 1.3. Assets cần chuẩn bị

```
assets/
├── images/
│   ├── logo.png                    # Logo ứng dụng (512x512)
│   ├── logo_dark.png               # Logo cho dark mode
│   ├── default_avatar.png          # Ảnh đại diện mặc định
│   ├── login_background.png        # Background màn hình đăng nhập
│   └── empty_state.png             # Hình minh họa khi danh sách trống
├── icons/
│   ├── department_icon.svg         # Icon phòng ban
│   ├── attendance_icon.svg         # Icon chấm công
│   ├── salary_icon.svg             # Icon lương
│   ├── leave_icon.svg              # Icon nghỉ phép
│   └── statistics_icon.svg         # Icon thống kê
└── fonts/                          # (Nếu dùng custom font)
    ├── Inter-Regular.ttf
    ├── Inter-Medium.ttf
    ├── Inter-SemiBold.ttf
    └── Inter-Bold.ttf
```

**Lưu ý:** Ưu tiên sử dụng icon từ Material Icons có sẵn trong Flutter để giảm kích thước APK. Chỉ dùng custom SVG icon khi Material Icons không có icon phù hợp.

---

## 2. API Contract và Backend

### 2.1. Lựa chọn Backend

Dự án hỗ trợ 2 hướng:

| Tiêu chí | REST API (Node.js/Express) | Firebase |
|-----------|---------------------------|----------|
| Kiểm soát | Toàn quyền | Hạn chế bởi Firebase rules |
| Chi phí | Tự host hoặc VPS | Free tier giới hạn |
| Tốc độ phát triển | Trung bình | Nhanh |
| Offline sync | Tự code | Firestore tích hợp sẵn |
| Phù hợp cho | Production, tùy biến cao | Prototype, MVP nhanh |

**Khuyến nghị cho MVP:** Sử dụng **mock data cục bộ (JSON)** trong giai đoạn phát triển UI, sau đó tích hợp backend thật khi UI hoàn thiện.

### 2.2. Tài liệu API (Swagger/OpenAPI 3.0)

#### Base URL
```
# Development
http://localhost:3000/api/v1

# Staging
https://staging-api.quanlynhanvien.com/api/v1
```

#### Authentication Endpoints

```yaml
POST /auth/login
  Request:
    {
      "username": "string",
      "password": "string"
    }
  Response 200:
    {
      "accessToken": "string (JWT)",
      "refreshToken": "string",
      "expiresIn": 3600,
      "user": {
        "id": "string",
        "username": "string",
        "role": "admin | manager | employee",
        "employeeId": "string | null"
      }
    }
  Response 401:
    { "error": "INVALID_CREDENTIALS", "message": "Sai tài khoản hoặc mật khẩu" }

POST /auth/refresh
  Request:
    { "refreshToken": "string" }
  Response 200:
    { "accessToken": "string", "expiresIn": 3600 }

POST /auth/logout
  Headers: Authorization: Bearer <token>
  Response 200:
    { "message": "Đăng xuất thành công" }
```

#### Employee Endpoints

```yaml
GET /employees
  Headers: Authorization: Bearer <token>
  Query Params:
    - page: int (default: 1)
    - limit: int (default: 20)
    - search: string (tìm theo tên hoặc mã NV)
    - departmentId: string (lọc theo phòng ban)
    - status: string (active | on_leave | resigned)
  Response 200:
    {
      "data": [
        {
          "id": "uuid",
          "employeeCode": "NV001",
          "fullName": "Nguyễn Văn A",
          "dateOfBirth": "1990-05-15",
          "gender": "male",
          "departmentId": "uuid",
          "departmentName": "Phòng Kỹ thuật",
          "positionId": "uuid",
          "positionName": "Lập trình viên",
          "phone": "0901234567",
          "email": "nguyenvana@company.com",
          "startDate": "2020-01-15",
          "contractType": "full_time",
          "baseSalary": 15000000,
          "status": "active",
          "avatarUrl": "https://..."
        }
      ],
      "pagination": {
        "page": 1,
        "limit": 20,
        "total": 150,
        "totalPages": 8
      }
    }

GET /employees/:id
  Response 200:
    { /* Single Employee object */ }

POST /employees
  Headers: Authorization: Bearer <token>
  Request:
    {
      "employeeCode": "NV002",
      "fullName": "Trần Thị B",
      "dateOfBirth": "1992-08-20",
      "gender": "female",
      "departmentId": "uuid",
      "positionId": "uuid",
      "phone": "0987654321",
      "email": "tranthib@company.com",
      "startDate": "2021-03-01",
      "contractType": "full_time",
      "baseSalary": 12000000,
      "status": "active"
    }
  Response 201:
    { "id": "uuid", "message": "Thêm nhân viên thành công" }
  Response 400:
    { "error": "VALIDATION_ERROR", "details": [...] }
  Response 409:
    { "error": "DUPLICATE_CODE", "message": "Mã nhân viên đã tồn tại" }

PUT /employees/:id
  Request: { /* Các trường cần cập nhật */ }
  Response 200:
    { "message": "Cập nhật thành công" }

DELETE /employees/:id
  Response 200:
    { "message": "Xóa nhân viên thành công" }
  Response 403:
    { "error": "FORBIDDEN", "message": "Không có quyền xóa" }
```

#### Department Endpoints

```yaml
GET /departments
  Response 200:
    {
      "data": [
        {
          "id": "uuid",
          "name": "Phòng Kỹ thuật",
          "managerId": "uuid",
          "managerName": "Nguyễn Văn A",
          "description": "Phòng phát triển phần mềm",
          "employeeCount": 25
        }
      ]
    }

POST /departments
  Request:
    { "name": "string", "managerId": "string | null", "description": "string" }
  Response 201:
    { "id": "uuid", "message": "Tạo phòng ban thành công" }

PUT /departments/:id
DELETE /departments/:id
```

#### Attendance Endpoints

```yaml
GET /attendance
  Query Params:
    - date: string (YYYY-MM-DD)
    - month: int
    - year: int
    - employeeId: string
  Response 200:
    {
      "data": [
        {
          "id": "uuid",
          "employeeId": "uuid",
          "employeeName": "Nguyễn Văn A",
          "date": "2024-01-15",
          "status": "present | absent_approved | absent_unapproved | late",
          "checkInTime": "08:05:00",
          "checkOutTime": "17:30:00",
          "note": ""
        }
      ]
    }

POST /attendance
  Request:
    {
      "records": [
        {
          "employeeId": "uuid",
          "date": "2024-01-15",
          "status": "present",
          "checkInTime": "08:00:00",
          "checkOutTime": "17:30:00",
          "note": ""
        }
      ]
    }
  Response 201:
    { "message": "Chấm công thành công", "count": 25 }

GET /attendance/summary
  Query Params:
    - month: int
    - year: int
    - employeeId: string (optional, nếu không truyền → tất cả NV)
  Response 200:
    {
      "data": [
        {
          "employeeId": "uuid",
          "employeeName": "Nguyễn Văn A",
          "totalWorkDays": 22,
          "presentDays": 20,
          "absentApproved": 1,
          "absentUnapproved": 1,
          "lateDays": 3
        }
      ]
    }
```

#### Salary Endpoints

```yaml
GET /salaries
  Query Params:
    - month: int
    - year: int
  Response 200:
    {
      "data": [
        {
          "id": "uuid",
          "employeeId": "uuid",
          "employeeName": "Nguyễn Văn A",
          "month": 1,
          "year": 2024,
          "workDays": 20,
          "baseSalary": 15000000,
          "allowance": 3000000,
          "deduction": 1575000,
          "netSalary": 16425000
        }
      ]
    }

POST /salaries/calculate
  Request:
    { "month": 1, "year": 2024 }
  Response 200:
    { "message": "Tính lương thành công", "count": 50 }
```

#### Leave Request Endpoints

```yaml
GET /leaves
  Query Params:
    - status: pending | approved | rejected
    - employeeId: string
  Response 200:
    {
      "data": [
        {
          "id": "uuid",
          "employeeId": "uuid",
          "employeeName": "Nguyễn Văn A",
          "startDate": "2024-01-20",
          "endDate": "2024-01-21",
          "reason": "Việc gia đình",
          "status": "pending",
          "approvedBy": null,
          "createdAt": "2024-01-18T10:00:00Z"
        }
      ]
    }

POST /leaves
  Request:
    {
      "employeeId": "uuid",
      "startDate": "2024-01-20",
      "endDate": "2024-01-21",
      "reason": "Việc gia đình"
    }
  Response 201:
    { "id": "uuid", "message": "Tạo đơn nghỉ phép thành công" }

PUT /leaves/:id/approve
  Response 200:
    { "message": "Đã duyệt đơn nghỉ phép" }

PUT /leaves/:id/reject
  Request:
    { "reason": "Lý do từ chối (optional)" }
  Response 200:
    { "message": "Đã từ chối đơn nghỉ phép" }
```

### 2.3. Mock Data (Dữ liệu test cục bộ)

Trong giai đoạn phát triển UI, sử dụng file JSON cục bộ đặt tại `assets/mock/`:

```
assets/mock/
├── employees.json          # 20-30 nhân viên mẫu
├── departments.json        # 5-7 phòng ban mẫu
├── positions.json          # 8-10 chức vụ mẫu
├── attendance_sample.json  # Dữ liệu chấm công 1 tháng
├── salary_sample.json      # Dữ liệu lương 1 tháng
└── leaves_sample.json      # 10-15 đơn nghỉ phép mẫu
```

**Cách sử dụng mock data trong Flutter:**
```dart
// services/mock_data_service.dart
class MockDataService {
  Future<List<Employee>> getEmployees() async {
    final jsonString = await rootBundle.loadString('assets/mock/employees.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Employee.fromJson(json)).toList();
  }
}
```

---

## 3. Cấu hình Hệ thống và Bảo mật

### 3.1. Cơ chế Xác thực (Authentication)

#### Phương án 1: JWT + Refresh Token (Khuyến nghị cho REST API)

```
Luồng xác thực:
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Client  │         │  Server  │         │    DB    │
└────┬─────┘         └────┬─────┘         └────┬─────┘
     │  POST /auth/login   │                    │
     │  {username, pass}   │                    │
     │────────────────────>│  Verify password   │
     │                     │───────────────────>│
     │                     │<───────────────────│
     │  {accessToken,      │                    │
     │   refreshToken}     │                    │
     │<────────────────────│                    │
     │                     │                    │
     │  GET /employees     │                    │
     │  Authorization:     │                    │
     │  Bearer <access>    │                    │
     │────────────────────>│  Verify JWT        │
     │                     │  (check expiry)    │
     │  200 OK + data      │                    │
     │<────────────────────│                    │
     │                     │                    │
     │  (Token hết hạn)    │                    │
     │  POST /auth/refresh │                    │
     │  {refreshToken}     │                    │
     │────────────────────>│  Verify refresh    │
     │  {new accessToken}  │                    │
     │<────────────────────│                    │
```

**Cấu hình JWT:**
- Access Token TTL: 1 giờ (3600s)
- Refresh Token TTL: 7 ngày
- Algorithm: HS256 hoặc RS256
- Payload: `{ userId, role, employeeId, iat, exp }`

**Lưu trữ token trên device:**
- Sử dụng `flutter_secure_storage` (Keychain trên iOS, EncryptedSharedPreferences trên Android)
- KHÔNG dùng SharedPreferences cho token (không mã hóa)

#### Phương án 2: Firebase Authentication

**Cấu hình cần thiết:**
- File `android/app/google-services.json` (Android)
- File `ios/Runner/GoogleService-Info.plist` (iOS)
- Bật Email/Password provider trong Firebase Console
- Custom Claims cho role: `admin`, `manager`, `employee`

```dart
// Cách set custom claims (phía server/Cloud Functions):
admin.auth().setCustomUserClaims(uid, { role: 'admin' });
```

### 3.2. Khởi tạo Database Cục bộ

#### Phương án 1: SQLite (sqflite) - Schema SQL

```sql
-- database_schema.sql

CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'manager', 'employee')),
    employee_id TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE departments (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    manager_id TEXT,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (manager_id) REFERENCES employees(id)
);

CREATE TABLE positions (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    allowance REAL NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE employees (
    id TEXT PRIMARY KEY,
    employee_code TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    date_of_birth TEXT,
    gender TEXT CHECK(gender IN ('male', 'female', 'other')),
    department_id TEXT,
    position_id TEXT,
    phone TEXT,
    email TEXT,
    start_date TEXT,
    contract_type TEXT CHECK(contract_type IN ('full_time', 'part_time', 'intern', 'contractor')),
    base_salary REAL NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'on_leave', 'resigned')),
    avatar_url TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (position_id) REFERENCES positions(id)
);

CREATE TABLE attendance (
    id TEXT PRIMARY KEY,
    employee_id TEXT NOT NULL,
    date TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('present', 'absent_approved', 'absent_unapproved', 'late')),
    check_in_time TEXT,
    check_out_time TEXT,
    note TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    UNIQUE(employee_id, date)
);

CREATE TABLE salaries (
    id TEXT PRIMARY KEY,
    employee_id TEXT NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    work_days INTEGER NOT NULL DEFAULT 0,
    base_salary REAL NOT NULL,
    allowance REAL NOT NULL DEFAULT 0,
    deduction REAL NOT NULL DEFAULT 0,
    net_salary REAL NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    UNIQUE(employee_id, month, year)
);

CREATE TABLE leave_requests (
    id TEXT PRIMARY KEY,
    employee_id TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    reason TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'approved', 'rejected')),
    approved_by TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

CREATE TABLE audit_logs (
    id TEXT PRIMARY KEY,
    actor_id TEXT NOT NULL,
    action_type TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id TEXT,
    payload TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indexes cho hiệu năng
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_code ON employees(employee_code);
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_salaries_employee_month ON salaries(employee_id, month, year);
CREATE INDEX idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX idx_leave_requests_status ON leave_requests(status);
```

#### Phương án 2: Hive - TypeAdapter Definitions

```dart
// models/employee_hive.dart
import 'package:hive/hive.dart';

part 'employee_hive.g.dart';

@HiveType(typeId: 0)
class EmployeeHive extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String employeeCode;
  @HiveField(2) late String fullName;
  @HiveField(3) String? dateOfBirth;
  @HiveField(4) String? gender;
  @HiveField(5) String? departmentId;
  @HiveField(6) String? positionId;
  @HiveField(7) String? phone;
  @HiveField(8) String? email;
  @HiveField(9) String? startDate;
  @HiveField(10) String? contractType;
  @HiveField(11) double baseSalary = 0;
  @HiveField(12) String status = 'active';
  @HiveField(13) String? avatarUrl;
}

// TypeId mapping:
// 0 - EmployeeHive
// 1 - DepartmentHive
// 2 - PositionHive
// 3 - AttendanceHive
// 4 - SalaryHive
// 5 - LeaveRequestHive
// 6 - UserHive
```

### 3.3. Bảo mật dữ liệu trên thiết bị

| Loại dữ liệu | Cách lưu trữ | Ghi chú |
|---------------|---------------|---------|
| Access Token | `flutter_secure_storage` | Mã hóa bằng Keychain/Keystore |
| Refresh Token | `flutter_secure_storage` | Mã hóa bằng Keychain/Keystore |
| Thông tin lương | SQLite + encryption | Dùng `sqflite_sqlcipher` nếu cần mã hóa DB |
| Dữ liệu chung (NV, phòng ban) | SQLite/Hive bình thường | Không nhạy cảm |
| Cấu hình app (theme, language) | SharedPreferences | Không nhạy cảm |

---

## 4. Chốt Quyết định Kỹ thuật (Tech Stack)

### 4.1. Quyết định cuối cùng

| Thành phần | Lựa chọn | Lý do |
|------------|-----------|-------|
| **State Management** | Riverpod | An toàn hơn Provider, compile-time safety, dễ test, không phụ thuộc BuildContext |
| **Local Storage** | SQLite (sqflite) | Dữ liệu có quan hệ phức tạp (1-n giữa Department↔Employee, Employee↔Attendance), hỗ trợ JOIN, INDEX |
| **Network Client** | Dio | Dễ cấu hình Interceptors (gắn Token, retry/backoff), hỗ trợ FormData upload ảnh |
| **Routing** | GoRouter | Declarative routing, deep linking support, redirect guards cho auth |
| **Date/Time** | intl | Format ngày tháng Việt Nam, đa ngôn ngữ |
| **Charts** | fl_chart | Lightweight, customizable, hỗ trợ PieChart và BarChart |
| **Secure Storage** | flutter_secure_storage | Lưu token an toàn |
| **Image Picker** | image_picker | Chọn/chụp ảnh đại diện |
| **UUID** | uuid | Generate ID cho offline-first |

### 4.2. pubspec.yaml (dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Database & Storage
  sqflite: ^2.3.3
  path: ^1.9.0
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.2.3

  # Networking
  dio: ^5.4.3+1
  connectivity_plus: ^6.0.3

  # UI Components
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1

  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Code Generation (annotations)
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code Generation
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0

  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

### 4.3. Cấu trúc thư mục nâng cao (theo Clean Architecture)

```
lib/
├── main.dart
├── app.dart                         # MaterialApp + Router + Theme
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   └── api_endpoints.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_interceptor.dart
│   │   └── network_info.dart
│   └── database/
│       ├── database_helper.dart
│       └── migrations/
│           ├── migration_v1.dart
│           └── migration_v2.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── employee/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── department/
│   ├── attendance/
│   ├── salary/
│   ├── leave/
│   └── statistics/
└── shared/
    └── widgets/
        ├── app_drawer.dart
        ├── loading_widget.dart
        ├── empty_state_widget.dart
        ├── error_widget.dart
        └── confirm_dialog.dart
```

### 4.4. Dio Interceptor Configuration

```dart
// core/network/api_interceptor.dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final newToken = await _refreshToken(refreshToken);
          // Retry original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // Refresh failed → logout
        }
      }
    }
    handler.next(err);
  }
}

// Retry Interceptor with exponential backoff
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({this.maxRetries = 3, this.initialDelay = const Duration(seconds: 1)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      for (int i = 0; i < maxRetries; i++) {
        await Future.delayed(initialDelay * pow(2, i));  // Exponential backoff
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          continue;
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
```

---

## 5. Tổng kết các việc cần chuẩn bị trước khi code

| # | Hạng mục | Trạng thái | Ưu tiên |
|---|----------|------------|---------|
| 1 | Chốt tech stack (Riverpod + SQLite + Dio) | ✅ Đã chốt | Cao |
| 2 | Thiết kế wireframe 11 màn hình | ⬜ Chưa làm | Cao |
| 3 | Chuẩn bị Design System (colors, typography, spacing) | ⬜ Chưa làm | Cao |
| 4 | Chuẩn bị assets (logo, default avatar, icons) | ⬜ Chưa làm | Trung bình |
| 5 | Viết SQL schema cho SQLite | ⬜ Chưa làm | Cao |
| 6 | Tạo mock data JSON cho test UI | ⬜ Chưa làm | Cao |
| 7 | Cấu hình Firebase hoặc JWT server | ⬜ Chưa làm | Trung bình |
| 8 | Setup Swagger/API docs | ⬜ Chưa làm | Thấp (nếu dùng mock) |

---

## 6. Ghi chú quan trọng

- **Offline-first approach:** SQLite là nguồn đọc chính. Mọi thao tác đọc đều từ local DB. Khi có mạng, sync lên server.
- **Code generation:** Chạy `flutter pub run build_runner build` sau khi tạo/sửa models với `@freezed` hoặc `@JsonSerializable`.
- **Test strategy:** Viết unit test cho logic tính lương, chấm công trước. Widget test cho form validation.
- **Git workflow:** Feature branch → Pull Request → Code Review → Merge to main.
