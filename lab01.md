```markdown
# HƯỚNG DẪN THỰC HÀNH BÀI 2: ỨNG DỤNG CÀI ĐẶT GIAO DIỆN (SETTINGS)

**Mục tiêu:** Xây dựng màn hình Cài đặt cho phép người dùng thay đổi kích thước chữ và chế độ tối (Dark Mode). Các cài đặt này phải được **lưu lại** và tự động áp dụng khi mở lại ứng dụng.

---

## BƯỚC 1: KHỞI TẠO VÀ CÀI ĐẶT

1.  **Tạo dự án mới:**
    Mở Terminal và chạy lệnh:
    ```bash
    flutter create lab2_settings
    ```

2.  **Thêm thư viện:**
    Mở file `pubspec.yaml`, thêm dòng sau vào phần `dependencies`:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      shared_preferences: ^2.2.0
    ```

3.  **Cập nhật thư viện:**
    Chạy lệnh: `flutter pub get`

---

## BƯỚC 2: XÂY DỰNG GIAO DIỆN CƠ BẢN (UI)

Mở file `lib/main.dart`. Xóa hết code cũ và tạo một khung `StatefulWidget` mới.

**Yêu cầu giao diện gồm 3 phần:**
1.  **Khu vực hiển thị thử:** Một đoạn văn bản mẫu để xem trước kết quả thay đổi.
2.  **Slider:** Để kéo chỉnh kích thước chữ.
3.  **Switch:** Để bật/tắt chế độ nền tối.

*Copy đoạn code khung dưới đây vào `main.dart`:*

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SettingsScreen(),
  ));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- KHAI BÁO BIẾN TRẠNG THÁI ---
  double _fontSize = 20.0; // Mặc định cỡ chữ là 20
  bool _isDarkMode = false; // Mặc định là chế độ Sáng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thay đổi màu nền dựa vào biến _isDarkMode
      backgroundColor: _isDarkMode ? const Color(0xFF333333) : Colors.white,
      
      appBar: AppBar(
        title: const Text("Cài đặt Giao diện"),
        backgroundColor: _isDarkMode ? Colors.black : Colors.blue,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PHẦN 1: VĂN BẢN MẪU
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Xin chào Lớp CNTT 17-11",
                style: TextStyle(
                  fontSize: _fontSize, // Áp dụng cỡ chữ từ biến
                  color: _isDarkMode ? Colors.white : Colors.black, // Đổi màu chữ
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // PHẦN 2: ĐIỀU KHIỂN CỠ CHỮ
            const Text("Kích thước chữ:", style: TextStyle(fontSize: 18, color: Colors.grey)),
            Slider(
              value: _fontSize,
              min: 10.0,
              max: 40.0,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
                // TODO: Gọi hàm lưu dữ liệu ở đây
              },
            ),

            const SizedBox(height: 20),

            // PHẦN 3: ĐIỀU KHIỂN CHẾ ĐỘ TỐI
            SwitchListTile(
              title: Text(
                "Chế độ tối (Dark Mode)",
                style: TextStyle(
                  fontSize: 18, 
                  color: _isDarkMode ? Colors.white : Colors.black
                ),
              ),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // TODO: Gọi hàm lưu dữ liệu ở đây
              },
            ),
          ],
        ),
      ),
    );
  }
}

```

---

## BƯỚC 3: VIẾT LOGIC LƯU TRỮ (SAVE)

Viết một hàm `_saveSettings` để lưu cả 2 giá trị (`_fontSize` và `_isDarkMode`) xuống ổ cứng mỗi khi người dùng thay đổi.

Thêm hàm này vào trong class `_SettingsScreenState`:

```dart
Future<void> _saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Lưu cỡ chữ (double)
  await prefs.setDouble('font_size', _fontSize);
  
  // Lưu chế độ tối (bool)
  await prefs.setBool('is_dark_mode', _isDarkMode);
  
  print("Đã lưu: Size=$_fontSize, DarkMode=$_isDarkMode");
}

```

**Nhiệm vụ:** Quay lại phần `build` giao diện, gọi hàm `_saveSettings()` vào sự kiện `onChanged` của Slider và Switch.

---

## BƯỚC 4: VIẾT LOGIC ĐỌC DỮ LIỆU (LOAD)

Khi mở app lên, ta cần đọc dữ liệu cũ để hiển thị đúng cài đặt trước đó.

1. Viết hàm `_loadSettings`:

```dart
Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  
  setState(() {
    // Đọc font_size, nếu chưa có (null) thì lấy mặc định 20.0
    _fontSize = prefs.getDouble('font_size') ?? 20.0;
    
    // Đọc chế độ tối, nếu chưa có (null) thì lấy mặc định false
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  });
}

```

2. Gọi hàm này trong `initState` (Hàm chạy đầu tiên khi mở màn hình):

```dart
@override
void initState() {
  super.initState();
  _loadSettings();
}

```

---

## BƯỚC 5: KIỂM THỬ (TESTING)

1. Chạy ứng dụng (`flutter run`).
2. Kéo Slider lên mức to nhất (ví dụ 40).
3. Bật Switch sang chế độ Tối (Nền đen).
4. **Tắt hẳn ứng dụng** (Kill App) hoặc nhấn nút Restart (màu xanh lá) trên VS Code.
5. Mở lại ứng dụng.
* *Kết quả mong đợi:* Chữ vẫn to và nền vẫn đen.
* *Nếu chữ về nhỏ và nền trắng:* Bạn chưa gọi `_loadSettings` trong `initState` hoặc chưa gọi `_saveSettings` trong `onChanged`.


