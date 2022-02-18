import 'dart:async';

import 'package:flutter/services.dart';

class Geoform {
  static const MethodChannel _channel = MethodChannel('geoform');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
