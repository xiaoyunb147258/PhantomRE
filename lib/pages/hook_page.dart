import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class HookPage extends StatefulWidget {
  const HookPage({super.key});
  @override
  State<HookPage> createState() => _HookPageState();
}

class _HookPageState extends State<HookPage> {
  String _out = '';
  bool _busy = false;
  final _pkg = TextEditingController();
  final _ctrl = TextEditingController(text: "Java.perform(function() {\n  // Frida 脚本\n});");
  static const _scripts = {
    'hook_log': '日志', 'dump_dex': 'Dex监控', 'bypass_ssl': 'SSL绕过',
    'bypass_signature': '签名绕过', 'list_classes': '列类',
    'list_methods': '列方法', 'trace_calls': '追踪调用',
  };

  Future<void> _load(String n) async {
    final s = await PlatformBridge.loadHookPreset(n);
    setState(() => _ctrl.text = s);
  }

  Future<void> _run() async {
    setState(() { _busy = true; _out = '>> 下发 Hook...'; });
    final r = await PlatformBridge.runHook(_ctrl.text, _pkg.text.trim());
    setState(() { _busy = false; _out = r; });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '动态 Hook',
      subtitle: '通用 Frida 执行能力。加载基础脚本或输入任意脚本执行；具体逻辑可由 AI 分析后生成。',
      icon: Icons.cable,
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _pkg, style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
              decoration: const InputDecoration(labelText: '目标包名（可留空）', hintText: 'com.example.app')),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _scripts.entries.map((e) => ActionChip(
              backgroundColor: AppTheme.card,
              label: Text(e.value, style: const TextStyle(fontSize: 12)),
              onPressed: () => _load(e.key))).toList()),
            const SizedBox(height: 12),
            TextField(controller: _ctrl, maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.neon),
              decoration: const InputDecoration(hintText: '// Frida JS')),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: _busy ? null : _run,
              icon: const Icon(Icons.play_arrow), label: Text(_busy ? '执行中' : '执行 Hook'))),
          ]))),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
