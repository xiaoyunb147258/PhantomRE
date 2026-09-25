import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class HookPage extends StatefulWidget {
  const HookPage({super.key});
  @override
  State<HookPage> createState() => _HookPageState();
}

class _HookPageState extends State<HookPage> {
  String _out = '';
  final _ctrl = TextEditingController(text: "Java.perform(function() {\n  // 你的 Frida Hook 脚本\n});");
  String _script = 'bypass_ssl.js';

  static const _presets = {
    'bypass_ssl.js': 'SSL Pinning 绕过',
    'bypass_signature.js': '签名校验绕过',
    'dump_dex.js': 'Dex Dump',
    'hook_log.js': 'Hook Log 输出',
  };

  Future<void> _loadPreset(String name) async {
    final s = await rootBundle.loadString('assets/frida_scripts/$name');
    setState(() { _script = name; _ctrl.text = s; });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '动态 Hook',
      subtitle: '内置 Frida Gadget，支持 Java/Native 层 Hook。可直接编辑脚本或使用预设脚本（SSL绕过/签名绕过/DexDump/日志Hook）。',
      icon: Icons.cable,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('预设脚本', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _presets.entries.map((e) => ActionChip(
                    backgroundColor: _script==e.key ? AppTheme.neon.withOpacity(0.2) : AppTheme.card,
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _loadPreset(e.key),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                const Text('脚本内容', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl, maxLines: 12,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.neon),
                  decoration: const InputDecoration(hintText: '// Frida JS'),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: FilledButton.icon(
                    onPressed: () => setState(() => _out = '>> 脚本已提交执行（内核加载后生效）\n$_script'),
                    icon: const Icon(Icons.play_arrow), label: const Text('执行 Hook'))),
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
