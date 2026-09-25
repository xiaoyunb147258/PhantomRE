import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tool_registry.dart';

/// AI 对话消息
class AiMessage {
  final String role; // system / user / assistant / tool
  final String? content;
  final List<Map<String, dynamic>>? toolCalls;
  final String? toolCallId;
  AiMessage({required this.role, this.content, this.toolCalls, this.toolCallId});

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{'role': role};
    if (content != null) m['content'] = content;
    if (toolCalls != null) m['tool_calls'] = toolCalls;
    if (toolCallId != null) m['tool_call_id'] = toolCallId;
    return m;
  }
}

class AIService {
  static const _kBase = 'ai_base_url';
  static const _kKey = 'ai_api_key';
  static const _kModel = 'ai_model';

  String baseUrl = 'https://api.openai.com/v1';
  String apiKey = '';
  String model = 'gpt-4o-mini';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = p.getString(_kBase) ?? baseUrl;
    apiKey = p.getString(_kKey) ?? '';
    model = p.getString(_kModel) ?? model;
  }

  Future<void> save(String b, String k, String m) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBase, b);
    await p.setString(_kKey, k);
    await p.setString(_kModel, m);
    baseUrl = b; apiKey = k; model = m;
  }

  bool get configured => apiKey.trim().isNotEmpty;

  /// 带工具调用的一轮对话；返回 (文本, 工具调用列表)
  Future<AiTurn> chatWithTools(List<AiMessage> messages) async {
    if (!configured) {
      return AiTurn(text: '[错误] 请先在设置里填写 API Key', toolCalls: []);
    }
    try {
      final url = Uri.parse('$baseUrl/chat/completions');
      final resp = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages.map((m) => m.toMap()).toList(),
          'tools': ToolRegistry.schemas(),
          'tool_choice': 'auto',
        }),
      ).timeout(const Duration(seconds: 120));
      if (resp.statusCode != 200) {
        return AiTurn(text: '[HTTP ${resp.statusCode}] ${resp.body}', toolCalls: []);
      }
      final j = jsonDecode(resp.body);
      final msg = j['choices'][0]['message'];
      final text = msg['content'] as String?;
      final calls = <Map<String, dynamic>>[];
      if (msg['tool_calls'] != null) {
        for (final c in msg['tool_calls']) {
          calls.add(Map<String, dynamic>.from(c));
        }
      }
      return AiTurn(text: text, toolCalls: calls);
    } catch (e) {
      return AiTurn(text: '[请求异常] $e', toolCalls: []);
    }
  }

  /// 兼容旧接口：纯文本对话
  Future<String> chat(List<Map<String, String>> messages) async {
    final msgs = messages.map((m) => AiMessage(role: m['role']!, content: m['content'])).toList();
    final turn = await chatWithTools(msgs);
    return turn.text ?? '';
  }
}

class AiTurn {
  final String? text;
  final List<Map<String, dynamic>> toolCalls;
  AiTurn({required this.text, required this.toolCalls});
}
