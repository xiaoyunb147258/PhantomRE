// trace_calls.js — 追踪指定方法的调用（供 AI 分析行为）
// 用法：设置 TARGET_CLASS / TARGET_METHOD
Java.perform(function () {
    var TARGET_CLASS = "";   // 例如 "com.example.LoginManager"
    var TARGET_METHOD = "";  // 例如 "checkVip"
    if (TARGET_CLASS === "" || TARGET_METHOD === "") {
        console.log("[!] 请设置 TARGET_CLASS / TARGET_METHOD");
        return;
    }
    try {
        var clz = Java.use(TARGET_CLASS);
        clz[TARGET_METHOD].overloads.forEach(function (ov) {
            ov.implementation = function () {
                var args = Array.prototype.slice.call(arguments);
                console.log("[TRACE] " + TARGET_CLASS + "." + TARGET_METHOD +
                    " called args=" + JSON.stringify(args));
                var ret = ov.apply(this, arguments);
                console.log("[TRACE] 返回 = " + ret);
                return ret;
            };
        });
        console.log("[+] 已追踪 " + TARGET_CLASS + "." + TARGET_METHOD);
    } catch (e) {
        console.log("[!] " + e);
    }
});
