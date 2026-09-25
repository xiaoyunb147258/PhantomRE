import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class DecryptPage extends StatefulWidget {
  const DecryptPage({super.key});
  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  String _out = '';
  @override
  Widget build(BuildContext context) {
    final funcs = [
      ['arsc 资源解析', '解析 resources.arsc 提取字符串/布局'],
      ['加密 assets 提取', '识别并解密加密资源文件'],
      ['图片资源导出', '导出所有 png/webp/9.png'],
      ['so 库提取', '导出所有 lib/*.so'],
      ['字符串解密', 'AI辅助还原混淆字符串'],
    ];
    return ToolPage(
      title: '资源解密',
      subtitle: '反编译并解密 APK 内的资源文件（arsc、加密assets、字符串表等）。',
      icon: Icons.lock_open,
      children: [
        ...funcs.map((f) => Card(
          child: ListTile(
            title: Text(f[0], style: const TextStyle(color: AppTheme.textMain)),
            subtitle: Text(f[1], style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            trailing: const Icon(Icons.key, color: Color(0xFFB06BFF)),
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
