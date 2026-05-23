import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Download sqlite3.wasm
  final wasmUrl = Uri.parse(
      'https://github.com/simolus3/sqlite3.dart'
      '/releases/download/sqlite3-2.4.6/sqlite3.wasm');

  print('Downloading sqlite3.wasm...');
  final wasmResponse = await http.get(wasmUrl);
  if (wasmResponse.statusCode == 200) {
    await File('web/sqlite3.wasm').writeAsBytes(wasmResponse.bodyBytes);
    print('OK: web/sqlite3.wasm (${wasmResponse.bodyBytes.length} bytes)');
  } else {
    print('FAIL: ${wasmResponse.statusCode}');
  }
}
