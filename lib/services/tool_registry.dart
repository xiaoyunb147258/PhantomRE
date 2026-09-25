import 'ai_service.dart';
import 'platform_bridge.dart';

/// 工具定义：AI 可调用的一个能力
class PhantomTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Future<String> Function(Map<String, dynamic> args) run;
  PhantomTool({required this.name, required this.description,
    required this.parameters, required this.run});

  Map<String, dynamic> toOpenAISchema() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    }
  };
}

/// 工具注册表：把软件所有能力注册成 AI 可调用的工具
class ToolRegistry {
  static final List<PhantomTool> tools = [
    PhantomTool(
      name: 'sandbox_run',
      description: '把目标APK安装/运行到内置免root虚拟沙盒中。逆向分析前必须先运行目标App。',
      parameters: {'type':'object','properties':{
        'apk_path':{'type':'string','description':'目标APK的本地路径'}},
        'required':['apk_path']},
      run: (a) async => await PlatformBridge.sandboxRun(a['apk_path'] ?? ''),
    ),
    PhantomTool(
      name: 'unpack',
      description: '对目标APK进行脱壳，dump出真实的dex文件。支持动态脱壳、静态脱壳、整体加固脱壳、so脱壳。',
      parameters: {'type':'object','properties':{
        'apk_path':{'type':'string'},
        'mode':{'type':'string','enum':['dynamic','static','packed','so']}},
        'required':['apk_path']},
      run: (a) async => await PlatformBridge.unpack(a['apk_path'] ?? '', a['mode'] ?? 'dynamic'),
    ),
    PhantomTool(
      name: 'decompile',
      description: '反编译APK或dex，得到Java源码或smali，用于分析应用逻辑（如会员判断、广告逻辑、Hook检测）。',
      parameters: {'type':'object','properties':{
        'target':{'type':'string'},
        'type':{'type':'string','enum':['java','smali','resources']}},
        'required':['target']},
      run: (a) async => await PlatformBridge.decompile(a['target'] ?? '', a['type'] ?? 'java'),
    ),
    PhantomTool(
      name: 'search_code',
      description: '在反编译结果中搜索代码，用于定位会员判断(isVip/unlock)、广告(ads)、Hook检测(frida/xposed)等关键逻辑。',
      parameters: {'type':'object','properties':{
        'keyword':{'type':'string','description':'要搜索的关键字，如 isVip / isPremium / frida / ads'}},
        'required':['keyword']},
      run: (a) async => await PlatformBridge.searchCode(a['keyword'] ?? ''),
    ),
    PhantomTool(
      name: 'gen_hook_script',
      description: '根据分析结果，让AI生成一段Frida Hook脚本，用于修改目标App行为（解锁会员、去广告、绕过检测）。',
      parameters: {'type':'object','properties':{
        'goal':{'type':'string','description':'Hook目标，如 让isVip返回true'},
        'target_class':{'type':'string','description':'目标类名'},
        'target_method':{'type':'string','description':'目标方法名'}},
        'required':['goal']},
      run: (a) async => '[脚本生成由AI在对话中完成] goal=' + (a['goal'] ?? ''),
    ),
    PhantomTool(
      name: 'run_hook',
      description: '在沙盒中运行Frida Hook脚本，动态修改目标App行为。',
      parameters: {'type':'object','properties':{
        'script':{'type':'string','description':'Frida JS脚本内容'},
        'package':{'type':'string','description':'目标应用包名'}},
        'required':['script']},
      run: (a) async => await PlatformBridge.runHook(a['script'] ?? '', a['package'] ?? ''),
    ),
    PhantomTool(
      name: 'bypass_signature',
      description: '去除/绕过目标App的签名校验和完整性检测。',
      parameters: {'type':'object','properties':{
        'apk_path':{'type':'string'}}, 'required':['apk_path']},
      run: (a) async => await PlatformBridge.bypassSignature(a['apk_path'] ?? ''),
    ),
    PhantomTool(
      name: 'bypass_detection',
      description: '绕过目标App的Hook检测/frida检测/xposed检测/root检测/模拟器检测。',
      parameters: {'type':'object','properties':{
        'types':{'type':'string','description':'检测类型，逗号分隔：frida,root,xposed,emulator'}},
        'required':['types']},
      run: (a) async => await PlatformBridge.bypassDetection(a['types'] ?? 'frida'),
    ),
    PhantomTool(
      name: 'decrypt_resources',
      description: '解密APK的资源文件，包括 /assets 目录和 /lib 目录下的加密文件，以及 resources.arsc。',
      parameters: {'type':'object','properties':{
        'apk_path':{'type':'string'},
        'target':{'type':'string','enum':['assets','lib','arsc','all']}},
        'required':['apk_path']},
      run: (a) async => await PlatformBridge.decryptResources(a['apk_path'] ?? '', a['target'] ?? 'all'),
    ),
    PhantomTool(
      name: 'capture_traffic',
      description: '抓取目标App的网络请求(HTTP/HTTPS)，配合SSL绕过可看到加密内容。',
      parameters: {'type':'object','properties':{
        'action':{'type':'string','enum':['start','stop','dump']}},
        'required':['action']},
      run: (a) async => await PlatformBridge.captureTraffic(a['action'] ?? 'start'),
    ),
    PhantomTool(
      name: 'read_log',
      description: '读取目标App的运行日志(logcat或Hook日志)，用于观察运行行为。',
      parameters: {'type':'object','properties':{
        'filter':{'type':'string','description':'过滤关键字'}},
        'required':[]},
      run: (a) async => await PlatformBridge.runShell('logcat -d -t 100 ' + (a['filter'] ?? '')),
    ),
    PhantomTool(
      name: 'one_click_repair',
      description: '一键脱修：依次执行 脱壳→去签名校验→防自毁→防杀进程→解密/assets→解密/lib。每步失败自动重试，仍失败则提示用户重试或跳过。',
      parameters: {'type':'object','properties':{
        'apk_path':{'type':'string'}}, 'required':['apk_path']},
      run: (a) async => await PlatformBridge.oneClickRepair(a['apk_path'] ?? ''),
    ),
    PhantomTool(
      name: 'run_shell',
      description: '在应用私有环境执行一条shell命令（非root）。用于高级操作。',
      parameters: {'type':'object','properties':{
        'cmd':{'type':'string'}}, 'required':['cmd']},
      run: (a) async => await PlatformBridge.runShell(a['cmd'] ?? ''),
    ),
  ];

  static PhantomTool? find(String name) {
    for (final t in tools) { if (t.name == name) return t; }
    return null;
  }

  static List<Map<String, dynamic>> schemas() =>
      tools.map((t) => t.toOpenAISchema()).toList();
}

/// 工具调用执行结果
class ToolCallResult {
  final String name;
  final String result;
  ToolCallResult(this.name, this.result);
}
