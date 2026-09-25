import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../services/tool_registry.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});
  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final AIService _ai = AIService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<AiMessage> _msgs = [];
  bool _busy = false;

  static const _system = '''你是 PhantomRE，一个安卓逆向工程 AI 助手。
你可以调用工具来完成用户的逆向需求：脱壳、反编译、搜索代码、Hook、去签名校验、绕过检测、解密资源、抓包、抓日志、一键脱修、沙盒运行。
典型任务：用户让你"分析会员功能/去广告/脱壳/绕过检测"时，你应先沙盒运行或反编译，再搜索关键代码，再生成Hook脚本，最后给出结论。
每次调用工具后，根据结果决定下一步。必要时多轮调用工具，直到得出可靠结论。
只做自有软件安全研究，不帮助攻击他人。'''
  ;

  @override
  void initState() {
    super.initState();
    _ai.load().then((_) => setState(() {}));
    _msgs.add(AiMessage(role: 'system', content: _system));
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty || _busy) return;
    _input.clear();
    setState(() {
      _msgs.add(AiMessage(role: 'user', content: t));
      _busy = true;
    });
    _scrollDown();
    await _agentLoop();
    setState(() => _busy = false);
    _scrollDown();
  }

  /// Agent 循环：AI 调工具 -> 执行 -> 结果回给 AI -> 直到 AI 给出最终答复
  Future<void> _agentLoop() async {
    for (int round = 0; round < 8; round++) {
      final turn = await _ai.chatWithTools(_msgs);
      // 记录 assistant 消息
      _msgs.add(AiMessage(role: 'assistant', content: turn.text, toolCalls: turn.toolCalls));
      if (turn.toolCalls.isEmpty) {
        // 没有工具调用 = 最终回复
        break;
      }
      setState(() {});
      _scrollDown();
      // 执行每个工具调用
      for (final call in turn.toolCalls) {
        final fn = call['function'];
        final name = fn['name'];
        Map<String, dynamic> args = {};
        try { args = jsonDecode(fn['arguments'] ?? '{}'); } catch (_) {}
        final tool = ToolRegistry.find(name);
        String result;
        if (tool == null) {
          result = 'ERR: unknown tool $name';
        } else {
          result = await tool.run(args);
        }
        // 把工具结果加进会话
        _msgs.add(AiMessage(role: 'tool', content: result, toolCallId: call['id']));
      }
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 逆向助手')),
      body: Column(children: [
        if (!_ai.configured)
          Container(
            width: double.infinity, color: AppTheme.warn.withOpacity(0.15),
            padding: const EdgeInsets.all(10),
            child: const Text('⚠ 未配置 AI，请到设置里填 Base URL / API Key / 模型',
              style: TextStyle(color: AppTheme.warn, fontSize: 12)),
          ),
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(12),
          itemCount: _msgs.length,
          itemBuilder: (ctx, i) {
            final m = _msgs[i];
            if (m.role == 'system') return const SizedBox.shrink();
            if (m.role == 'tool') {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
                ),
                child: SelectableText('🔧 工具结果: ' + (m.content ?? ''),
                  style: const TextStyle(color: AppTheme.neonBlue, fontSize: 11, fontFamily: 'monospace')),
              );
            }
            final isUser = m.role == 'user';
            // 工具调用的提示
            final calls = m.toolCalls ?? [];
            return Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (calls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('⚙ 调用工具: ' + calls.map((c) => c['function']['name']).join(', '),
                      style: const TextStyle(color: AppTheme.warn, fontSize: 11)),
                  ),
                if ((m.content ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.neon.withOpacity(0.15) : AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUser ? AppTheme.neon.withOpacity(0.4) : const Color(0xFF1F2733)),
                    ),
                    child: SelectableText(m.content ?? '',
                      style: TextStyle(color: isUser ? AppTheme.neon : AppTheme.textMain,
                        fontSize: 13, fontFamily: 'monospace')),
                  ),
              ],
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
              decoration: const InputDecoration(hintText: '说需求，如：分析这个App的会员功能并解锁'),
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
