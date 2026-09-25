import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class DecompilePage extends StatefulWidget {
  const DecompilePage({super.key});
  @override
  State<DecompilePage> createState() => _DecompilePageState();
}

class _DecompilePageState extends State<DecompilePage> {
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
    if (mode=='unzip') _out = await PlatformBridge.decompile(_apk!, 'apk');
    else if (mode=='manifest') _out = await PlatformBridge.parseManifest(_apk!);
    else if (mode=='scan') _out = await PlatformBridge.scanSensitive(_apk!);
    else _out = await PlatformBridge.searchCode(_apk!, 'vip');
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '反编译/静态分析',
      subtitle: '解包、解析 Manifest、扫描敏感信息、搜代码。',
      icon: Icons.code,
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
          ListTile(title: Text('解包 APK', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('提取全部文件', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('unzip'),),
          ListTile(title: Text('解析 Manifest', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('读清单', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('manifest'),),
          ListTile(title: Text('敏感信息扫描', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('找密钥/URL/接口', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('scan'),),
          ListTile(title: Text('搜代码', style: const TextStyle(color: AppTheme.textMain)), subtitle: Text('按关键字搜', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)), onTap: () => _run('search'),),
        ])),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
