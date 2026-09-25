// Signature Check Bypass
Java.perform(function() {
    var PackageManager = Java.use('android.app.ApplicationPackageManager');
    var Signature = Java.use('android.content.pm.Signature');
    PackageManager.getPackageInfo.overload('java.lang.String', 'int').implementation = function(pkg, flags) {
        var info = this.getPackageInfo(pkg, flags);
        if (info != null && info.signatures.value != null) {
            var sig = Signature.$new('308204...' /* fake */);
        }
        return info;
    };
    console.log('[+] Signature Bypass Hooked');
});
