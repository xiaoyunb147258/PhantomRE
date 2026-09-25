import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

/// Xposed 模块页（功能 30-32）：兼容层由 BlackBox 提供；这里做模块开关与导入
class ModulePage extends StatefulWidget {
  const ModulePage({super.key});
  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  String _out = '';
  final List<Map<String, dynamic>> _mods = [
    {'name': 'SSL Unpinning', 'on': false},
    {'name': '签名校验绕过', 'on': false},
    {'name': 'Root 隐藏', 'on': false},
    {'name': '日志增强', 'on': false},
  ];

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Xposed 模块',
      subtitle: 'BlackBox 内置 Xposed 兼容层，可加载标准模块（参考 VirtualXposed / LSPatch 思路）',
      icon: Icons.extension,
      children: [
        ..._mods.map((m) => Card(child: SwitchListTile(
          value: m['on'],
          activeColor: AppTheme.neon,
          title: Text(m['name'], style: const TextStyle(color: AppTheme.textMain)),
          subtitle: Text(m['on'] ? '已启用' : '已禁用', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
          onChanged: (v) => setState(() {
            m['on'] = v;
            _out = '模块 [${m['name']}] ${v ? '已启用' : '已禁用'}（沙盒内加载）';
          }),
        ))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _out = '导入模块：把 .apk 放入 assets/xposed_modules/ 后重新打包'),
          icon: const Icon(Icons.add), label: const Text('导入模块')),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
