import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

/// 一键脱修（功能 37）：脱壳→去签名→防自毁→防杀→解密assets→解密lib，带重试/跳过
class RepairPage extends StatefulWidget {
  const RepairPage({super.key});
  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  String _out = '';
  bool _busy = false;
  String? _apk;

  final List<(String, String, Future<String> Function(String))> _steps = [
    ('脱壳', 'Dump dex', (a) => PlatformBridge.unpack(a, '动态脱壳')),
    ('去签名校验', '绕过签名', (a) => PlatformBridge.bypassDetection('签名')),
    ('防自毁', '阻止自毁', (a) => PlatformBridge.bypassDetection('root')),
    ('防杀进程', '阻止被杀', (a) => PlatformBridge.bypassDetection('完整')),
    ('解密 /assets', '提取资源', (a) => PlatformBridge.decryptResources(a, 'assets')),
    ('解密 /lib', '提取 so', (a) => PlatformBridge.decryptResources(a, 'lib')),
  ];

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null) setState(() => _apk = r.files.single.path);
  }

  /// 执行一步，失败自动重试1次，仍失败询问用户重试/跳过
  Future<bool> _runStep(int i) async {
    final (name, _, act) = _steps[i];
    final apk = _apk!;
    setState(() { _busy = true; _out = '>> [${i + 1}/${_steps.length}] $name ...'; });

    String r = await act(apk);
    if (!r.startsWith('ERR')) {
      setState(() => _out = '>> $name ✓\n$r');
      _busy = false;
      return true;
    }
    // 自动重试 1 次
    setState(() => _out = '>> $name 失败，自动重试...');
    r = await act(apk);
    if (!r.startsWith('ERR')) {
      setState(() => _out = '>> $name ✓（重试成功）\n$r');
      _busy = false;
      return true;
    }
    // 询问用户
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('$name 失败', style: const TextStyle(color: AppTheme.warn)),
        content: Text(r, style: const TextStyle(color: AppTheme.textMain, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'skip'),
            child: const Text('跳过', style: TextStyle(color: AppTheme.textDim))),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'retry'),
            child: const Text('重试')),
        ],
      ),
    );
    if (choice == 'retry') return _runStep(i);
    _busy = false;
    return true; // 跳过
  }

  Future<void> _start() async {
    if (_apk == null) { setState(() => _out = '请先选择 APK'); return; }
    setState(() => _out = '=== 一键脱修开始 ===');
    for (int i = 0; i < _steps.length; i++) {
      await _runStep(i);
    }
    setState(() { _busy = false; _out += '\n=== 一键脱修结束 ==='; });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '一键脱修',
      subtitle: '脱壳+去签名+防自毁+防杀+解密 assets+lib，每步失败自动重试，仍失败可重试/跳过',
      icon: Icons.auto_fix_high,
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_apk ?? '未选择 APK', style: const TextStyle(color: AppTheme.textMain, fontSize: 12)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.folder_open), label: const Text('选择APK'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(onPressed: _busy ? null : _start,
                icon: const Icon(Icons.play_arrow), label: Text(_busy ? '执行中' : '一键脱修'))),
            ]),
          ]))),
        const SizedBox(height: 12),
        Card(child: Column(children: [
          for (int i = 0; i < _steps.length; i++) ListTile(
            dense: true,
            leading: const Icon(Icons.check_circle_outline, color: AppTheme.neon, size: 18),
            title: Text(_steps[i].$1, style: const TextStyle(color: AppTheme.textMain, fontSize: 13)),
            subtitle: Text(_steps[i].$2, style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
          ),
        ])),
        const SizedBox(height: 16),
        const Text('执行日志', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
