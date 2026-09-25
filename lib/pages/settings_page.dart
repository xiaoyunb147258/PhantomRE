import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _ai = AIService();
  final _base = TextEditingController();
  final _key = TextEditingController();
  final _model = TextEditingController();
  String _tip = '';

  @override
  void initState() {
    super.initState();
    _ai.load().then((_) {
      _base.text = _ai.baseUrl; _key.text = _ai.apiKey; _model.text = _ai.model;
      setState(() {});
    });
  }

  Future<void> _save() async {
    await _ai.save(_base.text.trim(), _key.text.trim(), _model.text.trim());
    setState(() => _tip = '已保存 ✓');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('AI 配置', style: TextStyle(color: AppTheme.neon, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: _base, style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
          decoration: const InputDecoration(labelText: 'Base URL', hintText: 'https://api.openai.com/v1')),
        const SizedBox(height: 12),
        TextField(controller: _key, obscureText: true, style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
          decoration: const InputDecoration(labelText: 'API Key')),
        const SizedBox(height: 12),
        TextField(controller: _model, style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
          decoration: const InputDecoration(labelText: '模型名称', hintText: 'gpt-4o-mini / deepseek-chat')),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('保存')),
        if (_tip.isNotEmpty) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_tip, style: const TextStyle(color: AppTheme.neon, fontSize: 13))),
        const SizedBox(height: 30),
        const Text('关于', style: TextStyle(color: AppTheme.neon, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('PhantomRE v1.0.0', style: TextStyle(color: AppTheme.textDim, fontSize: 13)),
        const SizedBox(height: 4),
        const Text('免Root 逆向工程平台 · 沙盒脱壳 / Hook / 签名绕过 / 抓包 / 反编译 · 内置AI助手',
          style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
      ]),
    );
  }
}
