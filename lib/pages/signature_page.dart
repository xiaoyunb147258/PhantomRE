import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

/// 签名/检测绕过页（功能 14-17）：去签名校验、完整性、root、模拟器
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

  Future<void> _run(String type) async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() { _busy = true; _out = '>> $type ...'; });
    final r = await PlatformBridge.bypassDetection(type);
    setState(() { _busy = false; _out = r; });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('去签名校验', '签名'),
      ('过完整性检测', '完整'),
      ('过 root 检测', 'root'),
      ('过模拟器检测', '模拟'),
    ];
    return ToolPage(
      title: '签名/检测绕过',
      subtitle: '生成绕过 Hook 并下发（参考 JustTrustMe / RootBeer-Bypass 等项目脚本）',
      icon: Icons.verified_user,
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_apk ?? '未选择 APK', style: const TextStyle(color: AppTheme.textMain, fontSize: 12)),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.folder_open), label: const Text('选择APK')),
          ]))),
        const SizedBox(height: 12),
        Card(child: Column(children: [
          for (final it in items) ListTile(
            title: Text(it.$1, style: const TextStyle(color: AppTheme.textMain)),
            subtitle: Text('生成 Frida 绕过脚本', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            trailing: const Icon(Icons.bolt, color: AppTheme.warn),
            onTap: () => _run(it.$2),
          ),
        ])),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
