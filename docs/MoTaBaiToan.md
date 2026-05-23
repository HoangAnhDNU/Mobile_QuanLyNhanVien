# QuanLyNhanVien - Mô tả bài toán (Research tổng hợp)

## 1. Tổng quan bài toán

### 1.1. Tên đề tài
Xây dựng ứng dụng mobile "Quản lý nhân viên" phục vụ bộ phận nhân sự/quản lý trong việc quản lý thông tin nhân viên, chấm công, tính lương và theo dõi hiệu suất làm việc theo thời gian thực.

### 1.2. Bối cảnh
Trong thực tế, dữ liệu nhân viên thường nằm rải rác ở file Excel, giấy tờ hành chính hoặc nhiều hệ thống khác nhau. Điều này gây:
- Khó đồng bộ dữ liệu nhân sự giữa các phòng ban.
- Mất thời gian tổng hợp báo cáo nhân sự, chấm công, lương.
- Dễ sai sót khi cập nhật thông tin nhân viên, hợp đồng lao động.
- Khó theo dõi lịch sử công tác, thăng chức, điều chuyển của nhân viên.

Theo mô tả chung của Human Resource Management System (HRMS), hệ thống cần hỗ trợ quản lý hồ sơ nhân viên, chấm công, tính lương, đánh giá hiệu suất và các báo cáo liên quan đến nhân sự.

### 1.3. Mục tiêu sản phẩm
- Tạo một ứng dụng mobile để quản lý thông tin nhân viên tập trung.
- Đảm bảo tra cứu nhanh, cập nhật kịp thời.
- Hỗ trợ làm việc ổn định ngay cả khi mạng yếu (offline-first cho các nghiệp vụ cốt lõi).
- Đảm bảo an toàn dữ liệu cá nhân và dữ liệu nhân sự.

## 2. Đối tượng sử dụng và phạm vi

### 2.1. Đối tượng sử dụng
- Quản trị viên/Phòng nhân sự: quản lý dữ liệu tổng thể, phân quyền, tính lương.
- Quản lý/Trưởng phòng: theo dõi nhân viên thuộc phòng ban, duyệt đơn nghỉ phép.
- Nhân viên (giai đoạn mở rộng): xem hồ sơ, chấm công, xem lương của bản thân.

### 2.2. Phạm vi MVP (đề xuất)
Phiên bản đầu tập trung vào nghiệp vụ quản lý nội bộ:
- Đăng nhập và phân quyền cơ bản.
- Quản lý hồ sơ nhân viên (CRUD).
- Quản lý phòng ban và chức vụ.
- Chấm công theo ngày.
- Tính lương cơ bản.
- Tra cứu và thống kê cơ bản.

Không nằm trong MVP:
- Quản lý tuyển dụng.
- Tích hợp hệ thống ERP đầy đủ.
- Chat in-app phức tạp.
- Quản lý đào tạo nội bộ.

## 3. Yêu cầu chức năng

### 3.1. Quản lý tài khoản và phân quyền
- Đăng nhập/đăng xuất.
- Quên mật khẩu (hoặc reset bởi quản trị).
- Phân quyền theo vai trò: `admin`, `manager`, `employee`.

### 3.2. Quản lý nhân viên
- Thêm/sửa/xóa/thống kê hồ sơ nhân viên.
- Trường thông tin tối thiểu:
  - Mã nhân viên, họ tên, ngày sinh, giới tính.
  - Phòng ban, chức vụ.
  - Số điện thoại, email.
  - Ngày vào làm, loại hợp đồng.
  - Lương cơ bản.
  - Trạng thái (đang làm, nghỉ phép, nghỉ việc).
  - Ảnh đại diện (tùy chọn).

### 3.3. Quản lý phòng ban
- Tạo/sửa/xóa phòng ban.
- Gán trưởng phòng cho phòng ban.
- Xem danh sách nhân viên theo phòng ban.

### 3.4. Quản lý chấm công
- Chấm công theo ngày: đi làm, vắng có phép, vắng không phép, đi trễ.
- Tổng hợp ngày công theo tháng.
- Cảnh báo vượt ngưỡng vắng cho phép.

### 3.5. Quản lý lương
- Tính lương dựa trên ngày công thực tế và lương cơ bản.
- Phụ cấp (chức vụ, ăn trưa, xăng xe).
- Khấu trừ (bảo hiểm, thuế TNCN cơ bản).
- Xuất bảng lương tháng.

### 3.6. Quản lý nghỉ phép
- Đơn xin nghỉ phép (từ nhân viên hoặc quản lý nhập).
- Duyệt/từ chối đơn nghỉ phép.
- Theo dõi số ngày phép còn lại.

### 3.7. Tra cứu, thống kê, báo cáo
- Tìm kiếm nhân viên theo mã, tên, phòng ban.
- Lọc danh sách theo phòng ban, chức vụ, trạng thái.
- Báo cáo:
  - Danh sách nhân viên theo phòng ban.
  - Bảng chấm công tháng.
  - Bảng lương tháng.
  - Thống kê nhân sự (tổng số, theo giới tính, theo phòng ban).
  - Danh sách nhân viên sắp hết hợp đồng.

## 4. Yêu cầu phi chức năng

### 4.1. Hiệu năng và khả dụng
- Thời gian mở màn hình danh sách chính < 2-3 giây trong điều kiện mạng ổn định.
- Tìm kiếm, lọc dữ liệu phản hồi nhanh (< 1 giây với bộ dữ liệu vừa).
- Giao diện rõ ràng, nhất quán, ưu tiên khả năng thao tác một tay.

### 4.2. Khả năng mở rộng
- Kiến trúc tách lớp rõ ràng để dễ mở rộng nghiệp vụ (tuyển dụng, đào tạo, KPI).
- Hỗ trợ bổ sung vai trò người dùng mới.

### 4.3. Tin cậy và đồng bộ
- Có cơ chế offline-first cho đọc dữ liệu cốt lõi.
- Có cơ chế retry/backoff khi đồng bộ thất bại.
- Đồng bộ lên server khi có kết nối trở lại.

### 4.4. Bảo mật và riêng tư
- Tuân thủ các nhóm rủi ro OWASP Mobile Top 10 (2024), đặc biệt:
  - Insecure Authentication/Authorization.
  - Insecure Data Storage.
  - Insecure Communication.
  - Insufficient Cryptography.
  - Security Misconfiguration.
- Không lưu thông tin nhạy cảm (lương, CMND) dạng plaintext trên thiết bị.
- Ghi log tối thiểu, tránh lộ dữ liệu cá nhân.

## 5. Quy tắc nghiệp vụ chính

1. Mã nhân viên là duy nhất trong toàn hệ thống.
2. Mỗi nhân viên chỉ thuộc một phòng ban tại một thời điểm.
3. Số ngày phép tối đa mặc định: 12 ngày/năm (có thể cấu hình).
4. Lương thực nhận được tính theo công thức:

$$
LuongThucNhan = (LuongCoBan / NgayCongChuan) \times NgayCongThucTe + PhuCap - KhauTru
$$

5. Nhân viên vắng không phép quá 5 ngày/tháng sẽ đưa vào danh sách cảnh báo.
6. Chỉ admin và manager mới được xem thông tin lương của nhân viên khác.

## 6. Mô hình dữ liệu đề xuất (mức logic)

### 6.1. Các thực thể chính
- `User(id, username, passwordHash, role, employeeId, status, createdAt)`
- `Employee(id, employeeCode, fullName, dateOfBirth, gender, departmentId, positionId, phone, email, startDate, contractType, baseSalary, status, avatarUrl)`
- `Department(id, name, managerId, description)`
- `Position(id, name, level, allowance)`
- `Attendance(id, employeeId, date, status, checkInTime, checkOutTime, note)`
- `Salary(id, employeeId, month, year, workDays, baseSalary, allowance, deduction, netSalary, createdAt)`
- `LeaveRequest(id, employeeId, startDate, endDate, reason, status, approvedBy, createdAt)`
- `AuditLog(id, actorId, actionType, targetType, targetId, payload, createdAt)`

### 6.2. Quan hệ dữ liệu
- `Department` 1-n `Employee`
- `Position` 1-n `Employee`
- `Employee` 1-n `Attendance`
- `Employee` 1-n `Salary`
- `Employee` 1-n `LeaveRequest`
- `User` 1-1 `Employee`

## 7. Kiến trúc app mobile đề xuất

Dựa trên hướng dẫn kiến trúc app hiện đại:
- Tách ít nhất 2 lớp: `UI layer` và `Data layer`.
- Có thể bổ sung `Domain layer` nếu nghiệp vụ tính lương/chấm công phức tạp.
- Áp dụng `Single Source of Truth` với local database là nguồn đọc chính.
- Sử dụng `Unidirectional Data Flow` để quản lý state và event ổn định.

### 7.1. Định hướng offline-first
- Local database (SQLite/Hive) là nguồn đọc chính.
- Repository quản lý 2 nguồn: local + network.
- Khi mất mạng:
  - Vẫn đọc được dữ liệu đã cache.
  - Ghi dữ liệu theo chiến lược queue/lazy write tùy nghiệp vụ.
- Khi có mạng lại:
  - Đồng bộ bằng background task, có retry exponential backoff.

### 7.2. Gợi ý công nghệ

| Thành phần | Công nghệ |
|------------|-----------|
| Framework | Flutter |
| Ngôn ngữ | Dart |
| CSDL cục bộ | SQLite (sqflite) hoặc Hive |
| State Management | Provider hoặc Riverpod |
| UI | Material Design 3 |
| Biểu đồ | fl_chart |
| Backend (tùy chọn) | REST API (Node.js/Java/.NET) hoặc Firebase |
| Xác thực | Firebase Authentication hoặc JWT + refresh token |

## 8. Giao diện/chức năng màn hình đề xuất

1. Màn hình Đăng nhập.
2. Màn hình Dashboard (số liệu tổng quan: tổng NV, NV mới, NV nghỉ phép hôm nay).
3. Màn hình Danh sách nhân viên + tìm kiếm/lọc.
4. Màn hình Chi tiết nhân viên.
5. Màn hình Form thêm/sửa nhân viên.
6. Màn hình Quản lý phòng ban.
7. Màn hình Chấm công.
8. Màn hình Bảng lương tháng.
9. Màn hình Quản lý nghỉ phép.
10. Màn hình Báo cáo thống kê.
11. Màn hình Cài đặt tài khoản.

## 9. Cấu trúc thư mục dự kiến

```
lib/
├── main.dart
├── models/
│   ├── employee.dart
│   ├── department.dart
│   ├── position.dart
│   ├── attendance.dart
│   ├── salary.dart
│   └── leave_request.dart
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── employee_list_screen.dart
│   ├── employee_detail_screen.dart
│   ├── employee_form_screen.dart
│   ├── department_screen.dart
│   ├── attendance_screen.dart
│   ├── salary_screen.dart
│   ├── leave_screen.dart
│   └── statistics_screen.dart
├── services/
│   └── database_service.dart
├── providers/
│   └── employee_provider.dart
└── widgets/
    ├── employee_card.dart
    ├── stat_card.dart
    └── search_bar.dart
```

## 10. Tiêu chí đánh giá kết quả đề tài

- Đầy đủ chức năng MVP theo mô tả.
- Dữ liệu được quản lý nhất quán, hạn chế trùng lặp.
- Hiệu năng sử dụng thực tế tốt trên thiết bị tầm trung.
- Có xử lý lỗi mạng và đồng bộ cơ bản.
- Đáp ứng yêu cầu bảo mật tối thiểu cho dữ liệu nhân sự.

## 11. Rủi ro và giải pháp giảm thiểu

- Rủi ro mất kết nối: áp dụng offline cache + queue đồng bộ.
- Rủi ro sai lệch dữ liệu khi đồng bộ: đặt quy tắc conflict resolution (last-write-wins kèm timestamp).
- Rủi ro lộ thông tin lương/cá nhân: mã hóa kênh truyền (HTTPS), phân quyền theo vai trò, hạn chế log nhạy cảm.
- Rủi ro quá tải khi mở rộng: tách repository, phân trang dữ liệu, tối ưu query.

## 12. Kế hoạch triển khai tham khảo (4 giai đoạn)

1. **Giai đoạn 1 - Phân tích và thiết kế:**
   - Chốt use case, entity, luồng dữ liệu, wireframe.
2. **Giai đoạn 2 - Xây dựng cốt lõi:**
   - Đăng nhập, quản lý nhân viên (CRUD), quản lý phòng ban.
3. **Giai đoạn 3 - Nghiệp vụ nhân sự:**
   - Chấm công, tính lương, nghỉ phép, báo cáo.
4. **Giai đoạn 4 - Hoàn thiện:**
   - Kiểm thử, tối ưu, bảo mật, tài liệu hướng dẫn.
