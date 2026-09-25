import 'package:flutter/services.dart';

class PlatformBridge {
  static const _ch = MethodChannel('com.phantom.re/native');

  static Future<String> ping() async {
    try { return await _ch.invokeMethod('ping'); }
    catch (e) { return 'ERR: $e'; }
  }

  static Future<Map> deviceInfo() async {
    try {
      final r = await _ch.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(r);
    } catch (e) { return {'error': '$e'}; }
  }

  static Future<bool> checkRoot() async {
    try { return await _ch.invokeMethod('checkRoot') ?? false; }
    catch (e) { return false; }
  }

  static Future<String> runShell(String cmd) async {
    try { return await _ch.invokeMethod('runShell', {'cmd': cmd}); }
    catch (e) { return 'ERR: $e'; }
  }

  static Future<String> installApk(String path) async {
    try { return await _ch.invokeMethod('installApk', {'path': path}); }
    catch (e) { return 'ERR: $e'; }
  }
}
