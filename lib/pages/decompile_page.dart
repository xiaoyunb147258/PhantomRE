import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class DecompilePage extends StatefulWidget {
  const DecompilePage({super.key});
  @override
  State<DecompilePage> createState() => _DecompilePageState();
}

class _DecompilePageState extends State<DecompilePage> {
  String _out = '';
  @override
  Widget build(BuildContext context) {
    final funcs = [
      ['DEX -> Java', 'jadx 反编译 dex 为 Java 源码'],
      ['APK -> smali', 'baksmali 反汇编为 smali'],
      ['资源 -> XML', 'apktool 还原 AndroidManifest 等'],
      ['Manifest 解析', '解析权限/组件/广播'],
      ['敏感信息扫描', '扫描硬编码密钥/API/地址'],
    ];
    return ToolPage(
      title: '反编译 / 静态分析',
      subtitle: '集成 jadx / apktool / baksmali，支持 DEX反编译、资源还原、smali编辑、敏感信息扫描。',
      icon: Icons.code,
      children: [
        ...funcs.map((f) => Card(
          child: ListTile(
            title: Text(f[0], style: const TextStyle(color: AppTheme.textMain)),
            subtitle: Text(f[1], style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF00E5C0)),
            onTap: () => setState(() => _out = '>> [${f[0]}] 已执行'),
          ),
        )),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
