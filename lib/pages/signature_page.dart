import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});
  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  String _out = '';
  @override
  Widget build(BuildContext context) {
    final funcs = [
      ['去除签名校验', 'Hook getPackageInfo/signatures 比对'],
      ['过完整性检测', 'Hook CRC/哈希 校验点'],
      ['绕过 root 检测', 'Hook File.exists / Runtime.exec'],
      ['绕过模拟器检测', 'Hook Build 属性'],
      ['SSL Pinning 绕过', 'Hook TrustManager'],
    ];
    return ToolPage(
      title: '签名绕过',
      subtitle: '通过 Xposed/Frida hook 绕过签名校验、完整性校验、环境检测。预设常用对抗脚本，一键执行。',
      icon: Icons.verified_user,
      children: [
        ...funcs.map((f) => Card(
          child: ListTile(
            title: Text(f[0], style: const TextStyle(color: AppTheme.textMain)),
            subtitle: Text(f[1], style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            trailing: const Icon(Icons.bolt, color: AppTheme.warn),
            onTap: () => setState(() => _out = '>> [${f[0]}] 已执行（内核加载后生效）'),
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
