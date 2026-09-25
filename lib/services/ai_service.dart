import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String> chat(List<Map<String, String>> messages) async {
    if (apiKey.isEmpty) return '[错误] 请先在设置里填写 API Key';
    try {
      final url = Uri.parse('$baseUrl/chat/completions');
      final resp = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({'model': model, 'messages': messages}),
      ).timeout(const Duration(seconds: 60));
      if (resp.statusCode != 200) {
        return '[HTTP ${resp.statusCode}] ${resp.body}';
      }
      final j = jsonDecode(resp.body);
      return j['choices'][0]['message']['content'] ?? '[空响应]';
    } catch (e) {
      return '[请求异常] $e';
    }
  }
}
