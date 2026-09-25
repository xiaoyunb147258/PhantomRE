import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});
  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String _out = '';
  bool _capturing = false;
  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '抓包',
      subtitle: '免 root 抓包：通过本地 VPN 模式捕获沙盒内应用的 HTTP(S) 流量，配合 SSL 绕过解密 HTTPS。',
      icon: Icons.wifi_tethering,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                SwitchListTile(
                  value: _capturing,
                  activeColor: AppTheme.neon,
                  title: const Text('启用抓包', style: TextStyle(color: AppTheme.textMain)),
                  subtitle: Text(_capturing ? '抓包中...' : '已停止', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
                  onChanged: (v) {
                    setState(() {
                      _capturing = v;
                      _out = v ? '>> VPN 抓包已启动（内核加载后生效）' : '>> 已停止';
                    });
                  },
                ),
                const Divider(color: Color(0xFF1F2733)),
                const ListTile(
                  dense: true,
                  leading: Icon(Icons.https, color: AppTheme.warn),
                  title: Text('SSL Pinning 绕过', style: TextStyle(color: AppTheme.textMain, fontSize: 13)),
                  subtitle: Text('配合 Hook 页的 bypass_ssl.js', style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
                ),
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
