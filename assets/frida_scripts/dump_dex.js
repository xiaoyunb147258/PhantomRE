// Dex Dump Script
Java.perform(function() {
    var DexFile = Java.use('dalvik.system.DexFile');
    var opened = [];
    DexFile.$init.overload('java.io.File').implementation = function(f) {
        var r = this.$init(f);
        opened.push(f.getAbsolutePath());
        console.log('[+] Dex loaded: ' + f.getAbsolutePath());
        return r;
    };
    console.log('[+] DexDump hooked');
});
