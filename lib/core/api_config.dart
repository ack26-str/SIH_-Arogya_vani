import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL for the FastAPI backend.
  /// Uses 10.0.2.2 for Android emulator to reach localhost, otherwise uses 127.0.0.1.
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api";
    } else {
      return "http://127.0.0.1:8000/api";
    }
  }
}
