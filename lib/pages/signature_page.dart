import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});
  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  String _out = '';
  String? _apk;
  bool _busy = false;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null) setState(() => _apk = r.files.single.path);
  }

  Future<void> _run(String mode) async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() { _busy = true; _out = '>> 处理中...'; });
    _out = await PlatformBridge.bypassDetection(mode);
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '签名/检测绕过',
      subtitle: '生成通用绕过脚本并执行（签名/完整性/root/模拟器）。',
      icon: Icons.verified_user,
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_apk ?? '未选择 APK', style: const TextStyle(color: AppTheme.textMain, fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _pick, icon: const Icon(Icons.folder_open), label: const Text('选择APK'))),
          ]))),
        const SizedBox(height: 12),
        Card(child: Column(children: [
          ListTile(title: Text('去签名校验', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('绕过签名比对', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('签名'),),
          ListTile(title: Text('过完整性检测', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('CRC/哈希自校验', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('完整'),),
          ListTile(title: Text('过 root 检测', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('隐藏 root 痕迹', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('root'),),
          ListTile(title: Text('过模拟器检测', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('伪装真机', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('模拟'),),
        ])),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
