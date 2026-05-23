# CHECKLIST THỰC HIỆN DỰ ÁN QUẢN LÝ NHÂN VIÊN

> **Tech Stack đã chốt:** Flutter + Riverpod + SQLite (sqflite) + Dio + GoRouter
> **Tham khảo chi tiết:** [ChiTietKyThuat.md](./ChiTietKyThuat.md)

---

## Giai đoạn 0: Chuẩn bị trước khi code

### 0.1. Thiết kế UI/UX
- [ ] Thiết kế wireframe/mockup 11 màn hình trên Figma
- [ ] Xác định navigation flow giữa các màn hình
- [ ] Chốt Design System: bảng màu, font chữ, spacing (xem ChiTietKyThuat.md §1.2)
- [ ] Chuẩn bị assets: logo, default_avatar, empty_state illustration
- [ ] Chuẩn bị icon SVG cho menu (department, attendance, salary, leave, statistics)

### 0.2. Chuẩn bị Mock Data
- [ ] Tạo `assets/mock/employees.json` (20-30 nhân viên mẫu)
- [ ] Tạo `assets/mock/departments.json` (5-7 phòng ban)
- [ ] Tạo `assets/mock/positions.json` (8-10 chức vụ)
- [ ] Tạo `assets/mock/attendance_sample.json` (chấm công 1 tháng)
- [ ] Tạo `assets/mock/salary_sample.json` (lương 1 tháng)
- [ ] Tạo `assets/mock/leaves_sample.json` (10-15 đơn nghỉ phép)

### 0.3. Chốt quyết định kỹ thuật
- [x] State Management: **Riverpod** (compile-time safety, dễ test)
- [x] Local Storage: **SQLite (sqflite)** (dữ liệu quan hệ phức tạp, hỗ trợ JOIN/INDEX)
- [x] Network Client: **Dio** (Interceptors gắn Token, retry/backoff)
- [x] Routing: **GoRouter** (declarative, redirect guards cho auth)
- [x] Authentication: **JWT + Refresh Token** (lưu bằng flutter_secure_storage)
- [x] Charts: **fl_chart** (PieChart, BarChart)
- [x] Code Generation: **freezed + json_serializable** (immutable models)

---

## Giai đoạn 1: Khởi tạo dự án & Thiết kế

### 1.1. Khởi tạo project
- [ ] Tạo Flutter project: `flutter create quan_ly_nhan_vien`
- [ ] Cấu hình `pubspec.yaml` với dependencies đã chốt:
  - `flutter_riverpod`, `riverpod_annotation`
  - `go_router`
  - `sqflite`, `path`
  - `dio`, `connectivity_plus`
  - `flutter_secure_storage`, `shared_preferences`
  - `fl_chart`, `google_fonts`
  - `intl`, `uuid`, `image_picker`, `cached_network_image`, `shimmer`
  - `freezed_annotation`, `json_annotation`
  - dev: `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`, `mockito`
- [ ] Tạo cấu trúc thư mục Clean Architecture:
  ```
  lib/
  ├── core/ (constants, theme, utils, network, database)
  ├── features/ (auth, employee, department, attendance, salary, leave, statistics)
  │   └── [feature]/ (data/, domain/, presentation/)
  └── shared/widgets/
  ```
- [ ] Tạo `core/constants/app_colors.dart` (bảng màu Light/Dark)
- [ ] Tạo `core/constants/app_sizes.dart` (spacing, radius, icon sizes)
- [ ] Tạo `core/theme/app_theme.dart` (Material Design 3 ThemeData)
- [ ] Tạo `core/theme/text_styles.dart` (typography hierarchy)
- [ ] Cấu hình GoRouter trong `app.dart` với redirect guard cho auth
- [ ] Tạo `main.dart` với ProviderScope wrapper

### 1.2. Thiết kế dữ liệu (Models với freezed + json_serializable)
- [ ] Tạo model `Employee` (id, employeeCode, fullName, dateOfBirth, gender, departmentId, positionId, phone, email, startDate, contractType, baseSalary, status, avatarUrl)
- [ ] Tạo model `Department` (id, name, managerId, description)
- [ ] Tạo model `Position` (id, name, level, allowance)
- [ ] Tạo model `Attendance` (id, employeeId, date, status, checkInTime, checkOutTime, note)
- [ ] Tạo model `Salary` (id, employeeId, month, year, workDays, baseSalary, allowance, deduction, netSalary)
- [ ] Tạo model `LeaveRequest` (id, employeeId, startDate, endDate, reason, status, approvedBy, createdAt)
- [ ] Tạo model `User` (id, username, passwordHash, role, employeeId, status)
- [ ] Chạy `flutter pub run build_runner build` để generate code

### 1.3. Thiết kế database (SQLite)
- [ ] Tạo `core/database/database_helper.dart` (singleton, khởi tạo DB, version management)
- [ ] Viết `migration_v1.dart` - CREATE TABLE cho tất cả 7 bảng + indexes (xem schema trong ChiTietKyThuat.md §3.2)
- [ ] Tạo DAO (Data Access Object) cho từng entity:
  - [ ] `EmployeeDao` (CRUD + search + filter by department/status)
  - [ ] `DepartmentDao` (CRUD + count employees)
  - [ ] `PositionDao` (CRUD)
  - [ ] `AttendanceDao` (CRUD + summary by month)
  - [ ] `SalaryDao` (CRUD + calculate)
  - [ ] `LeaveRequestDao` (CRUD + filter by status)
  - [ ] `UserDao` (CRUD + authenticate)
- [ ] Test kết nối và thao tác DB cơ bản

### 1.4. Cấu hình Network Layer
- [ ] Tạo `core/network/dio_client.dart` (base URL, timeout, interceptors)
- [ ] Tạo `core/network/auth_interceptor.dart` (gắn Bearer token + auto refresh)
- [ ] Tạo `core/network/retry_interceptor.dart` (exponential backoff khi mất mạng)
- [ ] Tạo `core/network/network_info.dart` (kiểm tra kết nối bằng connectivity_plus)
- [ ] Tạo `MockDataService` để load JSON cục bộ trong giai đoạn phát triển

### 1.5. Cấu hình Authentication
- [ ] Tạo `features/auth/data/datasources/auth_local_datasource.dart` (flutter_secure_storage: lưu/đọc/xóa token)
- [ ] Tạo `features/auth/data/repositories/auth_repository.dart` (login, refresh, logout)
- [ ] Tạo `features/auth/presentation/providers/auth_provider.dart` (Riverpod StateNotifier)
- [ ] Cấu hình GoRouter redirect: chưa login → LoginScreen, đã login → Dashboard

---

## Giai đoạn 2: Xây dựng cốt lõi

### 2.1. Màn hình Đăng nhập
- [ ] Tạo `features/auth/presentation/screens/login_screen.dart`
- [ ] UI: Logo app, TextField username, TextField password (obscure), nút Đăng nhập
- [ ] Validation: bắt buộc nhập, minimum length
- [ ] Logic: gọi AuthRepository.login() → lưu token → redirect Dashboard
- [ ] Lưu trạng thái đăng nhập (token trong flutter_secure_storage)
- [ ] Loading state khi đang xử lý
- [ ] Hiển thị lỗi khi sai tài khoản/mật khẩu

### 2.2. Màn hình Dashboard
- [ ] Tạo `features/employee/presentation/screens/dashboard_screen.dart`
- [ ] StatCard: Tổng số nhân viên (từ EmployeeDao.count())
- [ ] StatCard: Số NV mới trong tháng
- [ ] StatCard: Số NV nghỉ phép hôm nay
- [ ] StatCard: Tỉ lệ chấm công hôm nay
- [ ] PieChart: nhân viên theo phòng ban (fl_chart)
- [ ] Drawer menu điều hướng đến các màn hình khác (theo role)
- [ ] Tạo Riverpod provider cho dashboard data

### 2.3. Quản lý nhân viên - Danh sách
- [ ] Tạo `features/employee/presentation/screens/employee_list_screen.dart`
- [ ] Hiển thị danh sách nhân viên (ListView.builder)
- [ ] Tạo widget `employee_card.dart` (avatar, tên, mã NV, phòng ban, trạng thái badge)
- [ ] Thanh tìm kiếm (theo tên hoặc mã NV) với debounce
- [ ] FilterChips: lọc theo phòng ban
- [ ] FilterChips: lọc theo trạng thái (active, on_leave, resigned)
- [ ] FloatingActionButton thêm nhân viên mới → navigate Form
- [ ] Pull-to-refresh (RefreshIndicator)
- [ ] Shimmer loading placeholder
- [ ] Empty state widget khi không có dữ liệu
- [ ] Tạo `employee_list_provider.dart` (Riverpod + search/filter logic)

### 2.4. Quản lý nhân viên - Chi tiết
- [ ] Tạo `features/employee/presentation/screens/employee_detail_screen.dart`
- [ ] Hiển thị ảnh đại diện lớn (CachedNetworkImage + fallback default_avatar)
- [ ] Tab "Hồ sơ": thông tin cá nhân đầy đủ
- [ ] Tab "Chấm công": lịch sử chấm công gần đây
- [ ] Tab "Lương": lịch sử lương gần đây
- [ ] AppBar actions: nút Sửa (icon edit) → navigate đến Form
- [ ] AppBar actions: nút Xóa (icon delete) → ConfirmDialog → xóa → pop back
- [ ] SnackBar thông báo khi xóa thành công

### 2.5. Quản lý nhân viên - Form thêm/sửa
- [ ] Tạo `features/employee/presentation/screens/employee_form_screen.dart`
- [ ] TextField: mã NV (auto-generate nếu thêm mới), họ tên, SĐT, email, lương
- [ ] DatePicker: ngày sinh, ngày vào làm
- [ ] Dropdown: giới tính, phòng ban, chức vụ, loại hợp đồng, trạng thái
- [ ] ImagePicker: chọn/chụp ảnh đại diện
- [ ] Validation:
  - [ ] Email đúng format (RegExp)
  - [ ] SĐT đúng format (10-11 số, bắt đầu 0)
  - [ ] Mã NV không trùng (check DB)
  - [ ] Họ tên bắt buộc, min 2 ký tự
  - [ ] Lương >= 0
- [ ] Nút Lưu → insert/update qua EmployeeDao → pop back + SnackBar success
- [ ] Nút Hủy → ConfirmDialog nếu có thay đổi → pop back

### 2.6. Quản lý phòng ban
- [ ] Tạo `features/department/presentation/screens/department_screen.dart`
- [ ] Danh sách phòng ban (ListView) + badge số nhân viên
- [ ] Dialog/BottomSheet thêm/sửa phòng ban (name, description)
- [ ] Dropdown gán trưởng phòng (chọn từ danh sách nhân viên)
- [ ] Swipe-to-delete hoặc nút xóa + ConfirmDialog
- [ ] Tap vào phòng ban → xem danh sách NV thuộc phòng ban đó
- [ ] Tạo `department_provider.dart` (Riverpod)

---

## Giai đoạn 3: Nghiệp vụ nhân sự

### 3.1. Chấm công
- [ ] Tạo `features/attendance/presentation/screens/attendance_screen.dart`
- [ ] DatePicker chọn ngày chấm công (mặc định hôm nay)
- [ ] Danh sách nhân viên với dropdown trạng thái chấm công
- [ ] Trạng thái: present (đi làm), absent_approved (vắng có phép), absent_unapproved (vắng không phép), late (đi trễ)
- [ ] TimePicker cho giờ check-in/check-out
- [ ] Nút "Lưu chấm công" → batch insert AttendanceDao
- [ ] Tab "Tổng hợp": bảng tổng hợp ngày công theo tháng (MonthPicker)
- [ ] Highlight/cảnh báo nhân viên vắng không phép > 5 ngày/tháng (màu đỏ)
- [ ] Tạo `attendance_provider.dart`

### 3.2. Tính lương
- [ ] Tạo `features/salary/presentation/screens/salary_screen.dart`
- [ ] MonthPicker chọn tháng/năm tính lương
- [ ] Nút "Tính lương tháng" → gọi logic tính:
  ```
  NetSalary = (BaseSalary / StandardWorkDays) × ActualWorkDays + Allowance - Deduction
  ```
- [ ] DataTable hiển thị bảng lương tháng (tên NV, ngày công, lương cơ bản, phụ cấp, khấu trừ, thực nhận)
- [ ] Tap vào row → BottomSheet chi tiết lương nhân viên
- [ ] Phụ cấp breakdown: chức vụ (từ Position.allowance), ăn trưa, xăng xe
- [ ] Khấu trừ breakdown: BHXH 8%, BHYT 1.5%, BHTN 1%, thuế TNCN cơ bản
- [ ] Tạo `salary_calculator_service.dart` (business logic tách riêng)
- [ ] Tạo `salary_provider.dart`

### 3.3. Nghỉ phép
- [ ] Tạo `features/leave/presentation/screens/leave_screen.dart`
- [ ] TabBar: Chờ duyệt | Đã duyệt | Từ chối
- [ ] ListView đơn nghỉ phép (tên NV, ngày, lý do, status badge)
- [ ] FAB → Form tạo đơn nghỉ phép:
  - [ ] Dropdown chọn nhân viên (hoặc tự động nếu role employee)
  - [ ] DateRangePicker: ngày bắt đầu → ngày kết thúc
  - [ ] TextField: lý do
- [ ] Swipe action hoặc nút: Duyệt (chỉ admin/manager) → cập nhật status = approved
- [ ] Swipe action hoặc nút: Từ chối (chỉ admin/manager) → cập nhật status = rejected
- [ ] Hiển thị số ngày phép còn lại: 12 - (số ngày đã approved trong năm)
- [ ] Tạo `leave_provider.dart`

### 3.4. Báo cáo thống kê
- [ ] Tạo `features/statistics/presentation/screens/statistics_screen.dart`
- [ ] PieChart: phân bố nhân viên theo phòng ban (fl_chart)
- [ ] BarChart: nhân viên theo giới tính
- [ ] Summary cards: tổng NV đang làm, tổng NV nghỉ việc, NV mới tháng này
- [ ] DataTable: nhân viên sắp hết hợp đồng (< 30 ngày, tính từ startDate + contractDuration)
- [ ] Tỉ lệ chấm công tháng hiện tại (% ngày có mặt / tổng ngày làm việc)
- [ ] Tạo `statistics_provider.dart` (aggregate queries từ DB)

---

## Giai đoạn 4: Hoàn thiện

### 4.1. Phân quyền
- [ ] Tạo `core/utils/permission_helper.dart`
- [ ] Admin: full quyền (CRUD tất cả, xem lương, tính lương, duyệt phép)
- [ ] Manager: xem danh sách, chấm công, duyệt phép nhân viên phòng mình
- [ ] Employee (mở rộng): chỉ xem hồ sơ bản thân, xem lương bản thân, tạo đơn phép
- [ ] Ẩn/hiện nút và menu theo role (GoRouter redirect + conditional UI)
- [ ] Middleware kiểm tra quyền trước mỗi thao tác write

### 4.2. Giao diện & UX
- [ ] Hỗ trợ Light/Dark mode (toggle trong Settings, lưu SharedPreferences)
- [ ] Loading indicator: Shimmer placeholder cho danh sách
- [ ] Empty state widget (hình minh họa + text gợi ý hành động)
- [ ] Error state widget (icon lỗi + nút Thử lại)
- [ ] SnackBar thông báo thành công (màu xanh) / thất bại (màu đỏ)
- [ ] ConfirmDialog trước khi xóa (với tên đối tượng bị xóa)
- [ ] Responsive: LayoutBuilder cho tablet (2 column layout)
- [ ] Splash screen với logo app

### 4.3. Offline & Sync
- [ ] Implement connectivity listener (connectivity_plus)
- [ ] Queue thao tác write khi offline (bảng `pending_sync` trong SQLite)
- [ ] Sync pending operations khi có mạng trở lại
- [ ] Hiển thị banner "Đang offline" khi mất kết nối
- [ ] Retry với exponential backoff (RetryInterceptor)

### 4.4. Tối ưu & Test
- [ ] Phân trang danh sách (LIMIT/OFFSET trong SQLite query)
- [ ] Tối ưu query: sử dụng INDEX đã tạo, tránh N+1 queries
- [ ] Unit test: `salary_calculator_service.dart` (các trường hợp tính lương)
- [ ] Unit test: validation logic (email, SĐT, mã NV)
- [ ] Unit test: auth flow (login, refresh, logout)
- [ ] Widget test: form nhân viên (validation hiển thị đúng)
- [ ] Widget test: employee_card render đúng data
- [ ] Integration test: flow đăng nhập → dashboard → xem danh sách
- [ ] Kiểm tra phân quyền đúng theo role (3 roles)
- [ ] Test offline: tắt mạng → mở app → xem dữ liệu cached → bật mạng → sync

### 4.5. Tài liệu
- [ ] Viết README.md hướng dẫn cài đặt và chạy (prerequisites, setup, build)
- [ ] Viết báo cáo dự án (mô tả, kiến trúc Clean Architecture, kết quả)
- [ ] Chụp screenshot tất cả 11 màn hình (Light + Dark mode)
- [ ] Vẽ sơ đồ kiến trúc app (layers diagram)
- [ ] Vẽ sơ đồ ERD (quan hệ dữ liệu 7 bảng)
- [ ] Vẽ sơ đồ navigation flow
- [ ] Ghi chú hướng dẫn deploy/release APK

---

## Tóm tắt tiến độ

| Giai đoạn | Nội dung | Trạng thái |
|-----------|----------|------------|
| 0 | Chuẩn bị (UI/UX, Mock Data, Tech Stack) | 🟡 Tech Stack đã chốt, còn lại chưa làm |
| 1 | Khởi tạo & Thiết kế (Project, Models, DB, Network, Auth) | ⬜ Chưa bắt đầu |
| 2 | Xây dựng cốt lõi (Đăng nhập, Dashboard, CRUD NV, Phòng ban) | ⬜ Chưa bắt đầu |
| 3 | Nghiệp vụ (Chấm công, Lương, Nghỉ phép, Thống kê) | ⬜ Chưa bắt đầu |
| 4 | Hoàn thiện (Phân quyền, UX, Offline/Sync, Test, Tài liệu) | ⬜ Chưa bắt đầu |
