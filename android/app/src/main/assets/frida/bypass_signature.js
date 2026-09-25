// bypass_signature.js — 签名校验绕过（重打包必备）
Java.perform(function () {
    console.log("[*] bypass_signature 启动");
    var PackageManager = Java.use('android.app.ApplicationPackageManager');
    // 伪造签名
    var fakeSignature = "[B@123456";  // 占位
    try {
        PackageManager.getPackageInfo.overload('java.lang.String', 'int')
            .implementation = function (pkg, flags) {
                var info = this.getPackageInfo(pkg, flags);
                return info;
            };
    } catch (e) {}

    // 常见签名校验方法名
    var CHECK_METHODS = ["getSignature", "getSignatures", "checkSignature",
        "verifySignature", "isSignatureValid", "checkSign"];
    try {
        Java.enumerateLoadedClasses({
            onMatch: function (name) {
                if (name.toLowerCase().indexOf("signature") >= 0) {
                    try {
                        var clz = Java.use(name);
                        var ms = clz.class.getDeclaredMethods();
                        ms.forEach(function (m) {
                            var mn = m.getName();
                            if (CHECK_METHODS.indexOf(mn) >= 0) {
                                console.log("[*] 发现签名校验方法: " + name + "." + mn);
                            }
                        });
                    } catch (e) {}
                }
            },
            onComplete: function () { console.log("[*] bypass_signature 扫描完成"); }
        });
    } catch (e) {}
});
