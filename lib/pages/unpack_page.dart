import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class UnpackPage extends StatefulWidget {
  const UnpackPage({super.key});
  @override
  State<UnpackPage> createState() => _UnpackPageState();
}

class _UnpackPageState extends State<UnpackPage> {
  String _out = '';
  String? _apk;
  String _mode = '动态脱壳';

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null) setState(() => _apk = r.files.single.path);
  }

  Future<void> _run() async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() => _out = '>> [$_mode] 脱壳中，请稍候...\n目标: $_apk');
    // 真实脱壳：调用 BlackBox 沙盒 + DexDumper
    final r = await PlatformBridge.unpack(_apk!, _mode);
    setState(() => _out = r);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '脱壳',
      subtitle: '支持动态脱壳（运行时Dump Dex/so）、静态脱壳、整体加固脱壳、多dex拆分。内核基于 BlackDex + FRIDA-DEXDump。',
      icon: Icons.layers,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _mode, isExpanded: true,
                  dropdownColor: AppTheme.card,
                  items: const [
                    DropdownMenuItem(value:'动态脱壳', child: Text('动态脱壳 (运行时Dump)')),
                    DropdownMenuItem(value:'静态脱壳', child: Text('静态脱壳 (不运行)')),
                    DropdownMenuItem(value:'整体加固', child: Text('整体加固脱壳')),
                    DropdownMenuItem(value:'so脱壳', child: Text('so 层脱壳')),
                  ],
                  onChanged: (v) => setState(() => _mode = v!),
                ),
                const SizedBox(height: 10),
                Text(_apk ?? '未选择 APK', style: const TextStyle(color: AppTheme.textMain, fontSize: 13)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _pick,
                    icon: const Icon(Icons.folder_open), label: const Text('选择APK'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: _run,
                    icon: const Icon(Icons.play_arrow), label: const Text('开始脱壳'))),
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
