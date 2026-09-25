// SSL Pinning Bypass
Java.perform(function() {
    var TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    var SSLContext = Java.use('javax.net.ssl.SSLContext');
    var TrustManagerImpl = Java.registerClass({
        name: 'com.phantom.TrustAll',
        implements: [TrustManager],
        methods: {
            checkClientTrusted: function(chain, authType) {},
            checkServerTrusted: function(chain, authType) {},
            getAcceptedIssuers: function() { return []; }
        }
    });
    var ctx = SSLContext.getInstance('TLS');
    ctx.init(null, [TrustManagerImpl.$new()], null);
    SSLContext.init.overload('[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom')
        .implementation = function(a,b,c) { this.init(null, [TrustManagerImpl.$new()], c); };
    console.log('[+] SSL Pinning Bypassed');
});
