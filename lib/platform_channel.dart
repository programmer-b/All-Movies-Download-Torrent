import 'package:flutter/services.dart';

class PlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.example.app/screenshot');

  static Future<void> disableScreenshots() async {
    try {
      await _channel.invokeMethod('disableScreenshots');
    } on PlatformException catch (e) {
      print("Failed to disable screenshots: '${e.message}'.");
    }
  }
}