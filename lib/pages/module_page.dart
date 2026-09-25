import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class ModulePage extends StatefulWidget {
  const ModulePage({super.key});
  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  String _out = '';
  final List<Map<String, dynamic>> _mods = [
    {'name':'去签名校验模块', 'on':false},
    {'name':'SSL Unpinning', 'on':false},
    {'name':'防检测/隐藏环境', 'on':false},
    {'name':'脱壳模块 (BlackDex类)', 'on':false},
    {'name':'日志增强', 'on':false},
  ];
  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Xposed 模块',
      subtitle: '内置 Xposed 兼容层，支持加载标准 Xposed 模块（去校验/SSL绕过/防检测/脱壳等）。可把模块 apk 放入 assets/xposed_modules。',
      icon: Icons.extension,
      children: [
        ..._mods.map((m) => Card(
          child: SwitchListTile(
            value: m['on'],
            activeColor: AppTheme.neon,
            title: Text(m['name'], style: const TextStyle(color: AppTheme.textMain)),
            subtitle: Text(m['on'] ? '已启用' : '已禁用', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            onChanged: (v) => setState(() { m['on']=v;
              _out = '>> 模块 [${m['name']}] $v' + (v ? ' 已启用（内核加载后生效）' : ' 已禁用'); }),
          ),
        )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _out = '>> 模块导入：把 .apk 放入 assets/xposed_modules 后重新打包'),
          icon: const Icon(Icons.add), label: const Text('导入模块')),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
