import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});
  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String _out = '';
  bool _on = false;

  Future<void> _ctl(String act) async {
    final r = await PlatformBridge.captureTraffic(act);
    setState(() => _out = r);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '抓包',
      subtitle: '免root抓包（本地VPN代理）。HTTPS 需先到 Hook 页执行 bypass_ssl.js。',
      icon: Icons.wifi_tethering,
      children: [
        Card(child: Column(children: [
          SwitchListTile(value: _on, activeColor: AppTheme.neon,
            title: const Text('启用抓包', style: TextStyle(color: AppTheme.textMain)),
            subtitle: Text(_on ? '抓包中' : '已停止', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            onChanged: (v) { setState(() => _on = v); _ctl(v ? 'start' : 'stop'); }),
          const Divider(color: Color(0xFF1F2733)),
          ListTile(title: const Text('查看抓包结果', style: TextStyle(color: AppTheme.textMain)),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.neon),
            onTap: () => _ctl('dump')),
        ])),
        const SizedBox(height: 16),
        const Text('输出', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _out),
      ],
    );
  }
}
