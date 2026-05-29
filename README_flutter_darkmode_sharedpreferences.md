# Lab Flutter Bài 5: Dark Mode / Light Mode với Provider và SharedPreferences

## 1\. Mục tiêu

Sau khi hoàn thành bài lab, sinh viên có thể:

* Tạo giao diện Flutter hỗ trợ **Light Mode** và **Dark Mode**.
* Sử dụng `Provider` để quản lý trạng thái theme.
* Sử dụng `SharedPreferences` để lưu lựa chọn theme của người dùng.
* Khi tắt app và mở lại, app vẫn giữ đúng chế độ sáng/tối đã chọn.
* Biết tách logic quản lý theme ra khỏi UI.

\---

## 2\. Yêu cầu kiến thức trước khi làm

Sinh viên cần nắm các nội dung sau:

* Widget cơ bản trong Flutter.
* `StatelessWidget` và `StatefulWidget`.
* `MaterialApp`, `Scaffold`, `AppBar`, `Card`, `SwitchListTile`.
* Khái niệm `Provider` và `ChangeNotifier`.
* Khái niệm lưu trữ cục bộ bằng `SharedPreferences`.

\---

## 3\. Cài đặt package

Trong terminal của project Flutter, chạy:

```bash
flutter pub add provider
flutter pub add shared\_preferences
```

Sau đó chạy:

```bash
flutter pub get
```

\---

## 4\. Cấu trúc thư mục yêu cầu

Sinh viên cần tổ chức project theo cấu trúc tối thiểu như sau:

```text
lib/
├── main.dart
├── providers/
│   └── theme\_provider.dart
└── screens/
    └── home\_screen.dart
```

Có thể mở rộng thêm:

```text
lib/
├── main.dart
├── providers/
│   └── theme\_provider.dart
├── screens/
│   ├── home\_screen.dart
│   └── setting\_screen.dart
└── widgets/
    └── theme\_card.dart
```

\---

## 5\. Tạo ThemeProvider

Tạo file:

```text
lib/providers/theme\_provider.dart
```

Nội dung mẫu:

```dart
import 'package:flutter/material.dart';
import 'package:shared\_preferences/shared\_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String \_themeKey = 'is\_dark\_mode';

  bool \_isDarkMode = false;

  bool get isDarkMode => \_isDarkMode;

  ThemeMode get themeMode {
    return \_isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    \_isDarkMode = prefs.getBool(\_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    \_isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(\_themeKey, value);
  }
}
```

\---

## 6\. Cấu hình main.dart

Mở file:

```text
lib/main.dart
```

Nội dung mẫu:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme\_provider.dart';
import 'screens/home\_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (\_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark Mode Demo',

      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
```

\---

## 7\. Tạo HomeScreen

Tạo file:

```text
lib/screens/home\_screen.dart
```

Nội dung mẫu:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme\_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode / Light Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: \[
            SwitchListTile(
              title: const Text('Bật Dark Mode'),
              subtitle: Text(
                themeProvider.isDarkMode
                    ? 'Ứng dụng đang dùng Dark Mode'
                    : 'Ứng dụng đang dùng Light Mode',
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const \[
                    Text(
                      'Ví dụ nội dung',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Khi đổi theme, màu nền, màu chữ, AppBar và Card sẽ tự thay đổi theo ThemeData.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {},
              child: const Text('Nút thử nghiệm'),
            ),
          ],
        ),
      ),
    );
  }
}
```

\---

## 8\. Luồng hoạt động

```text
Người dùng bật/tắt Switch
        ↓
Gọi themeProvider.toggleTheme(value)
        ↓
Provider cập nhật \_isDarkMode
        ↓
notifyListeners()
        ↓
MaterialApp build lại
        ↓
themeMode đổi sang Light hoặc Dark
        ↓
SharedPreferences lưu is\_dark\_mode
        ↓
Tắt app mở lại vẫn giữ theme đã chọn
```

\---

## 9\. Kiểm tra dữ liệu SharedPreferences trên Flutter Web

Nếu chạy app trên Chrome hoặc Edge:

```text
F12
→ Application
→ Storage
→ Local storage
→ localhost
```

Tìm key:

```text
flutter.is\_dark\_mode
```

Giá trị:

```text
true
```

nghĩa là đang lưu Dark Mode.

```text
false
```

nghĩa là đang lưu Light Mode.

Nếu muốn xóa dữ liệu demo, mở tab Console và chạy:

```javascript
localStorage.clear()
```

\---

