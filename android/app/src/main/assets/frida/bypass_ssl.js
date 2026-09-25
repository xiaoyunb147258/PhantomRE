// bypass_ssl.js — SSL Pinning 绕过（HTTPS 抓包必备）
Java.perform(function () {
    console.log("[*] bypass_ssl 启动");
    try {
        var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
        var SSLContext = Java.use('javax.net.ssl.SSLContext');
        var TrustAll = Java.registerClass({
            name: 'com.phantom.TrustAll',
            implements: [X509TrustManager],
            methods: {
                checkClientTrusted: function (chain, authType) {},
                checkServerTrusted: function (chain, authType) {},
                getAcceptedIssuers: function () { return []; }
            }
        });
        var ctx = SSLContext.getInstance("TLS");
        ctx.init(null, [TrustAll.$new()], null);
        SSLContext.init.overload(
            '[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom'
        ).implementation = function (a, b, c) {
            this.init(null, [TrustAll.$new()], c);
        };
        // 常见 OkHttp / HostnameVerifier
        try {
            var OkHostname = Java.use('okhttp3.internal.tls.OkHostnameVerifier');
            OkHostname.verify.overloads.forEach(function (ov) {
                ov.implementation = function () { return true; };
            });
        } catch (e) {}
        console.log("[+] SSL Pinning 已绕过");
    } catch (e) { console.log("[!] " + e); }
});
