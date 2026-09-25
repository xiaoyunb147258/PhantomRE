import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/tool.dart';
import '../services/platform_bridge.dart';
import 'sandbox_page.dart';
import 'unpack_page.dart';
import 'hook_page.dart';
import 'signature_page.dart';
import 'decrypt_page.dart';
import 'decompile_page.dart';
import 'capture_page.dart';
import 'log_page.dart';
import 'module_page.dart';
import 'ai_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _deviceLine = 'device: loading...';

  final List<ToolItem> tools = const [
    ToolItem(title:'虚拟沙盒', desc:'安装/运行APK到内置沙盒', icon:Icons.security, color:AppTheme.neon, route:'sandbox'),
    ToolItem(title:'脱壳', desc:'整体加固/动态/静态脱壳', icon:Icons.layers, color:AppTheme.neonBlue, route:'unpack'),
    ToolItem(title:'动态Hook', desc:'Frida脚本执行与编辑', icon:Icons.cable, color:Color(0xFFFF7A00), route:'hook'),
    ToolItem(title:'签名绕过', desc:'去签名校验/过完整性', icon:Icons.verified_user, color:AppTheme.warn, route:'signature'),
    ToolItem(title:'资源解密', desc:'arsc/assets解密提取', icon:Icons.lock_open, color:Color(0xFFB06BFF), route:'decrypt'),
    ToolItem(title:'反编译', desc:'DEX->Java / 资源->XML', icon:Icons.code, color:Color(0xFF00E5C0), route:'decompile'),
    ToolItem(title:'抓包', desc:'免root VPN抓HTTP(S)', icon:Icons.wifi_tethering, color:Color(0xFF4DA6FF), route:'capture'),
    ToolItem(title:'日志', desc:'logcat + Hook日志', icon:Icons.terminal, color:AppTheme.warn, route:'log'),
    ToolItem(title:'Xposed模块', desc:'模块管理/一键启用', icon:Icons.extension, color:Color(0xFFFF5E9C), route:'module'),
    ToolItem(title:'AI助手', desc:'逆向问答/脚本生成', icon:Icons.psychology, color:AppTheme.neon, route:'ai'),
  ];

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final info = await PlatformBridge.deviceInfo();
    final rooted = await PlatformBridge.checkRoot();
    if (!mounted) return;
    setState(() {
      _deviceLine = '${info['model'] ?? '?'} · Android ${info['android'] ?? '?'} · '
          'SDK ${info['sdk'] ?? '?'} · ${rooted ? "已Root" : "未Root"}';
    });
  }

  void _go(String route) {
    Widget p;
    switch (route) {
      case 'sandbox': p = const SandboxPage(); break;
      case 'unpack': p = const UnpackPage(); break;
      case 'hook': p = const HookPage(); break;
      case 'signature': p = const SignaturePage(); break;
      case 'decrypt': p = const DecryptPage(); break;
      case 'decompile': p = const DecompilePage(); break;
      case 'capture': p = const CapturePage(); break;
      case 'log': p = const LogPage(); break;
      case 'module': p = const ModulePage(); break;
      case 'ai': p = const AiPage(); break;
      default: p = const SettingsPage();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => p));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhantomRE'),
        actions: [
          IconButton(onPressed: () => _go('settings'),
            icon: const Icon(Icons.settings)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D3B2E), Color(0xFF0A1F2E)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neon.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('免Root · 逆向工程平台',
                    style: TextStyle(color: AppTheme.neon, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_deviceLine, style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 1.05),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final t = tools[i];
                  return InkWell(
                    onTap: () => _go(t.route),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.color.withOpacity(0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(t.icon, color: t.color, size: 30),
                          const Spacer(),
                          Text(t.title, style: const TextStyle(
                            color: AppTheme.textMain, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(t.desc, style: const TextStyle(
                            color: AppTheme.textDim, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
                childCount: tools.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
