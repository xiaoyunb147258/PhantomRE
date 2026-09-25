import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});
  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String _out = '';
  final _filter = TextEditingController();

  Future<void> _grab() async {
    setState(() => _out = '>> 读取日志...');
    final r = await PlatformBridge.readLog(_filter.text.trim());
    setState(() => _out = r.isEmpty ? '(无日志)' : r);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '日志',
      subtitle: '读取 logcat 日志。可输入过滤关键字（如 TAG）。',
      icon: Icons.terminal,
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          TextField(controller: _filter,
            style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
            decoration: const InputDecoration(hintText: '过滤关键字')),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _grab, icon: const Icon(Icons.refresh), label: const Text('抓取日志'))),
        ]))),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
