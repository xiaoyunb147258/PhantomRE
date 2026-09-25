// Hook Log
Java.perform(function() {
    var Log = Java.use('android.util.Log');
    ['d','e','i','v','w'].forEach(function(lev) {
        Log[lev].overload('java.lang.String','java.lang.String').implementation = function(t,m){
            console.log('[' + lev.toUpperCase() + '] ' + t + ': ' + m);
            return this[lev](t,m);
        };
    });
});
