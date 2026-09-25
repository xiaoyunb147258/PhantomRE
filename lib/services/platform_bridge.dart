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

  static Future<String> sandboxRun(String apkPath) async {
    try { return await _ch.invokeMethod('sandboxRun', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> unpack(String apkPath, String mode) async {
    try { return await _ch.invokeMethod('unpack', {'apk_path': apkPath, 'mode': mode}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> decompile(String target, String type) async {
    try { return await _ch.invokeMethod('decompile', {'apk_path': target, 'type': type}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> searchCode(String apkPath, String keyword) async {
    try { return await _ch.invokeMethod('searchCode', {'apk_path': apkPath, 'keyword': keyword}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> parseManifest(String apkPath) async {
    try { return await _ch.invokeMethod('parseManifest', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> scanSensitive(String apkPath) async {
    try { return await _ch.invokeMethod('scanSensitive', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> extractStrings(String apkPath) async {
    try { return await _ch.invokeMethod('extractStrings', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> loadHookPreset(String name) async {
    try { return await _ch.invokeMethod('loadHookPreset', {'name': name}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> readLog(String filter) async {
    try { return await _ch.invokeMethod('readLog', {'filter': filter}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> runHook(String script, String packageName) async {
    try { return await _ch.invokeMethod('runHook', {'script': script, 'package': packageName}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> bypassSignature(String apkPath) async {
    try { return await _ch.invokeMethod('bypassSignature', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> bypassDetection(String types) async {
    try { return await _ch.invokeMethod('bypassDetection', {'types': types}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> decryptResources(String apkPath, String target) async {
    try { return await _ch.invokeMethod('decryptResources', {'apk_path': apkPath, 'target': target}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> captureTraffic(String action) async {
    try { return await _ch.invokeMethod('captureTraffic', {'action': action}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }

  static Future<String> oneClickRepair(String apkPath) async {
    try { return await _ch.invokeMethod('oneClickRepair', {'apk_path': apkPath}); }
    catch (e) { return 'ERR(kernel): $e'; }
  }
}
