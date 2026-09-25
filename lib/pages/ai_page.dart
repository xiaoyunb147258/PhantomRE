import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});
  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final AI _ai = AI();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _msgs = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ai.load().then((_) => setState(() {}));
    _msgs.add({'role':'system','content':'你是 PhantomRE 逆向工程助手，帮助用户完成脱壳、Hook、签名绕过、资源解密、抓包等工作，可生成 Frida/Xposed 脚本。'});
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty || _busy) return;
    _input.clear();
    setState(() { _msgs.add({'role':'user','content':t}); _busy = true; });
    _scrollDown();
    final reply = await _ai.chat(_msgs);
    setState(() { _msgs.add({'role':'assistant','content':reply}); _busy = false; });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 助手')),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(12),
          itemCount: _msgs.length,
          itemBuilder: (ctx, i) {
            final m = _msgs[i];
            if (m['role'] == 'system') return const SizedBox.shrink();
            final isUser = m['role'] == 'user';
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.neon.withOpacity(0.15) : AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isUser ? AppTheme.neon.withOpacity(0.4) : const Color(0xFF1F2733)),
                ),
                child: SelectableText(m['content'] ?? '',
                  style: TextStyle(color: isUser ? AppTheme.neon : AppTheme.textMain,
                    fontSize: 13, fontFamily: 'monospace')),
              ),
            );
          },
        )),
        if (_busy) const Padding(
          padding: EdgeInsets.all(8),
          child: LinearProgressIndicator(backgroundColor: Color(0xFF1F2733), color: AppTheme.neon),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          color: AppTheme.bg,
          child: Row(children: [
            Expanded(child: TextField(
              controller: _input,
              style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
              decoration: const InputDecoration(hintText: '问点什么，比如：帮我写个去签名校验的Frida脚本'),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
          ]),
        ),
      ]),
    );
  }
}

// 兼容包装：真实实现见 services/ai_service.dart
class AI extends AIService {}
