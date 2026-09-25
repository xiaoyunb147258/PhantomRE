// dump_dex.js — 动态 Dex Dump（内存脱壳）
Java.perform(function () {
    console.log("[*] dump_dex 启动");
    var dexFiles = [];

    // Hook DexFile 构造，记录所有加载的 dex
    try {
        var DexFile = Java.use('dalvik.system.DexFile');
        DexFile.$init.overload('java.io.File').implementation = function (f) {
            console.log("[DEX] 加载: " + f.getAbsolutePath());
            dexFiles.push(f.getAbsolutePath());
            return this.$init(f);
        };
        DexFile.$init.overload('java.lang.String').implementation = function (p) {
            console.log("[DEX] 加载: " + p);
            dexFiles.push(p);
            return this.$init(p);
        };
    } catch (e) {}

    // Hook ClassLoader 的 dex 加载
    try {
        var BaseDexClassLoader = Java.use('dalvik.system.BaseDexClassLoader');
        BaseDexClassLoader.$init.overload('java.lang.String', 'java.io.File', 'java.lang.String', 'java.lang.ClassLoader')
            .implementation = function (a, b, c, d) {
                console.log("[DEX-CL] " + a);
                return this.$init(a, b, c, d);
            };
    } catch (e) {}

    console.log("[+] dump_dex 已启用，运行 App 触发加载后会打印所有 dex 路径");
});
