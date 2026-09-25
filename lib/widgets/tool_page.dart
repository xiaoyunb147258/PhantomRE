import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ToolPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  const ToolPage({super.key, required this.title, required this.subtitle,
    required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Icon(icon, color: AppTheme.neon, size: 36),
                const SizedBox(width: 14),
                Expanded(child: Text(subtitle,
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 13))),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class Console extends StatelessWidget {
  final String text;
  const Console({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2733)),
      ),
      child: SelectableText(
        text.isEmpty ? '// 输出将显示在这里' : text,
        style: const TextStyle(color: AppTheme.neon, fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}
