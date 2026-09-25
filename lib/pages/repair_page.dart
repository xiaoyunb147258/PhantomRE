import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_page.dart';
import '../services/platform_bridge.dart';

/// 一键脱修步骤
class RepairStep {
  final String name;
  final String desc;
  final Future<String> Function(String apk) action;
  RepairStep(this.name, this.desc, this.action);
}

enum StepState { pending, running, retrying, success, failed, skipped }

class RepairPage extends StatefulWidget {
  const RepairPage({super.key});
  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  String? _apk;
  String _log = '';
  bool _running = false;

  final List<RepairStep> _steps = [
    RepairStep('脱壳', 'Dump 出真实 dex', (a) => PlatformBridge.unpack(a, 'dynamic')),
    RepairStep('去签名校验', '绕过签名/完整性检测', (a) => PlatformBridge.bypassSignature(a)),
    RepairStep('防自毁', '阻止应用自毁逻辑', (a) => PlatformBridge.bypassDetection('selfdestruct')),
    RepairStep('防杀进程', '阻止被外部杀进程', (a) => PlatformBridge.bypassDetection('kill')),
    RepairStep('解密 /assets', '解密 assets 目录资源', (a) => PlatformBridge.decryptResources(a, 'assets')),
    RepairStep('解密 /lib', '解密 lib 目录 so 文件', (a) => PlatformBridge.decryptResources(a, 'lib')),
  ];

  final List<StepState> _states = List.generate(6, (_) => StepState.pending);

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (r != null && r.files.single.path != null) {
      setState(() => _apk = r.files.single.path);
    }
  }

  void _append(String s) {
    setState(() => _log = '$_log\n$s');
  }

  /// 执行单个步骤，失败自动重试1次；仍失败则询问用户
  Future<bool> _runStep(int i) async {
    final step = _steps[i];
    final apk = _apk!;

    // 第1次
    setState(() => _states[i] = StepState.running);
    _append('▶ [${i+1}/${_steps.length}] ${step.name} ...');
    String r = await step.action(apk);
    if (!r.startsWith('ERR')) {
      setState(() => _states[i] = StepState.success);
      _append('  ✓ ${step.name} 成功');
      return true;
    }

    // 自动重试1次
    setState(() => _states[i] = StepState.retrying);
    _append('  ⚠ ${step.name} 失败，自动重试 1 次...');
    await Future.delayed(const Duration(milliseconds: 800));
    r = await step.action(apk);
    if (!r.startsWith('ERR')) {
      setState(() => _states[i] = StepState.success);
      _append('  ✓ ${step.name} 重试成功');
      return true;
    }

    // 仍失败 → 询问用户
    setState(() => _states[i] = StepState.failed);
    _append('  ✗ ${step.name} 仍失败: $r');
    if (!mounted) return false;
    final choice = await _askUser(step.name);
    if (choice == 'retry') {
      return await _runStep(i); // 手动重试（递归）
    } else {
      setState(() => _states[i] = StepState.skipped);
      _append('  ⏭ 已跳过 ${step.name}');
      return true;
    }
  }

  Future<String> _askUser(String stepName) async {
    final r = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('步骤失败：$stepName', style: const TextStyle(color: AppTheme.warn)),
        content: const Text('该步骤执行失败。你可以手动重试，或跳过此步骤继续。',
          style: TextStyle(color: AppTheme.textMain)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'skip'),
            child: const Text('跳过', style: TextStyle(color: AppTheme.textDim))),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'retry'),
            child: const Text('手动重试')),
        ],
      ),
    );
    return r ?? 'skip';
  }

  Future<void> _start() async {
    if (_apk == null) { setState(() => _log = '请先选择 APK'); return; }
    setState(() {
      _running = true;
      _log = '=== 一键脱修开始 ===\n目标: $_apk';
      for (int i = 0; i < _states.length; i++) { _states[i] = StepState.pending; }
    });
    for (int i = 0; i < _steps.length; i++) {
      final ok = await _runStep(i);
      if (!ok && !mounted) return;
    }
    setState(() => _running = false);
    _append('\n=== 一键脱修结束 ===');
  }

  Widget _stepRow(int i) {
    final st = _states[i];
    IconData icon; Color color;
    switch (st) {
      case StepState.pending: icon = Icons.circle_outlined; color = AppTheme.textDim; break;
      case StepState.running: icon = Icons.sync; color = AppTheme.neonBlue; break;
      case StepState.retrying: icon = Icons.refresh; color = AppTheme.warn; break;
      case StepState.success: icon = Icons.check_circle; color = AppTheme.neon; break;
      case StepState.failed: icon = Icons.error; color = AppTheme.danger; break;
      case StepState.skipped: icon = Icons.skip_next; color = AppTheme.textDim; break;
    }
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(_steps[i].name, style: TextStyle(color: color, fontSize: 13)),
      subtitle: Text(_steps[i].desc, style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: '一键脱修',
      subtitle: '全自动：脱壳 → 去签名校验 → 防自毁 → 防杀进程 → 解密/assets → 解密/lib。每步失败自动重试，仍失败可手动重试或跳过。',
      icon: Icons.auto_fix_high,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_apk ?? '未选择 APK', style: const TextStyle(color: AppTheme.textMain, fontSize: 13)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _running ? null : _pick,
                    icon: const Icon(Icons.folder_open), label: const Text('选择APK'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: _running ? null : _start,
                    icon: const Icon(Icons.play_arrow), label: Text(_running ? '执行中' : '一键脱修'))),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: [for (int i = 0; i < _steps.length; i++) _stepRow(i)])),
        const SizedBox(height: 16),
        const Text('执行日志', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        const SizedBox(height: 8),
        Console(text: _log),
      ],
    );
  }
}
