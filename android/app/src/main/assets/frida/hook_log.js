// hook_log.js — 日志 Hook（打印 App 内部日志）
Java.perform(function () {
    console.log("[*] hook_log 启动");
    var Log = Java.use('android.util.Log');
    ['v', 'd', 'i', 'w', 'e'].forEach(function (lev) {
        try {
            Log[lev].overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
                console.log("[" + lev.toUpperCase() + "] " + tag + ": " + msg);
                return this[lev](tag, msg);
            };
        } catch (e) {}
    });
    console.log("[+] 日志 Hook 已启用");
});
