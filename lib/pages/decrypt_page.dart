import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

/// 资源解密页（功能 18-21）：assets/lib/arsc/图片/字符串 提取
class DecryptPage extends StatefulWidget {
  const DecryptPage({super.key});
  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  String _out = '';
  String? _apk;
  bool _busy = false;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null) setState(() => _apk = r.files.single.path);
  }

  Future<void> _run(String target) async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() { _busy = true; _out = '>> 提取中...'; });
    final r = await PlatformBridge.decryptResources(_apk!, target);
    setState(() { _busy = false; _out = r; });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('解密 /assets', 'assets'),
      ('解密 /lib (so)', 'lib'),
      ('提取全部资源', 'all'),
      ('提取字符串', 'strings'),
    ];
    return ToolPage(
      title: '资源解密',
      subtitle: '提取/解密 assets、lib、图片、arsc、字符串（apktool 思路，内置实现）',
      icon: Icons.lock_open,
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
            subtitle: Text('提取到 /sdcard/Download/PhantomRE/resource', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            trailing: const Icon(Icons.key, color: Color(0xFFB06BFF)),
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
