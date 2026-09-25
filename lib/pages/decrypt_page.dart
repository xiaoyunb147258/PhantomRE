import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

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

  Future<void> _run(String mode) async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() { _busy = true; _out = '>> 处理中...'; });
    _out = mode == 'strings' ? await PlatformBridge.extractStrings(_apk!) : await PlatformBridge.decryptResources(_apk!, mode);
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '资源解密',
      subtitle: '提取/解密 assets、lib、图片、arsc 等资源。',
      icon: Icons.lock_open,
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
          ListTile(title: Text('解密 assets', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('提取 assets 目录', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('assets'),),
          ListTile(title: Text('解密 lib', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('提取所有 so', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('lib'),),
          ListTile(title: Text('提取全部', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('assets+lib+图片+arsc', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('all'),),
          ListTile(title: Text('提取字符串', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('从 dex/arsc 抽字符串', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('strings'),),
        ])),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
