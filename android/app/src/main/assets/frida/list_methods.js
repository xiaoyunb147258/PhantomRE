// list_methods.js — 列举指定类的方法（供 AI 分析）
// 用法：把 TARGET_CLASS 改成目标类名
Java.perform(function () {
    var TARGET_CLASS = "";  // 例如 "com.example.UserManager"
    if (TARGET_CLASS === "") {
        console.log("[!] 请在脚本中设置 TARGET_CLASS");
        return;
    }
    try {
        var clz = Java.use(TARGET_CLASS);
        var methods = clz.class.getDeclaredMethods();
        methods.forEach(function (m) {
            console.log("[METHOD] " + TARGET_CLASS + " -> " +
                m.getName() + " : " + m.getReturnType().getName());
        });
        console.log("[*] 共 " + methods.length + " 个方法");
    } catch (e) {
        console.log("[!] " + e);
    }
});
