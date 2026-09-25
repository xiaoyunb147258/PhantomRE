import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class SandboxPage extends StatefulWidget {
  const SandboxPage({super.key});
  @override
  State<SandboxPage> createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  String _out = '';
  String? _picked;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null && r.files.single.path != null) {
      setState(() => _picked = r.files.single.path);
    }
  }

  Future<void> _install() async {
    if (_picked == null) { setState(() => _out = '请先选择一个 APK'); return; }
    setState(() => _out = '>> 正在唤起安装器...');
    final r = await PlatformBridge.installApk(_picked!);
    setState(() => _out = r);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '虚拟沙盒',
      subtitle: '内置沙盒环境，可把目标APK装入并在沙盒内运行（免root）。内核加载后，脱壳/Hook/抓包均在此环境内进行。',
      icon: Icons.security,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_picked ?? '未选择 APK', style: const TextStyle(
                  color: AppTheme.textMain, fontSize: 13)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: _pick, icon: const Icon(Icons.folder_open),
                    label: const Text('选择APK'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(
                    onPressed: _install, icon: const Icon(Icons.play_arrow),
                    label: const Text('装入沙盒'))),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
