// list_classes.js — 列举已加载的类（供 AI 分析定位目标）
Java.perform(function () {
    console.log("[*] 列举已加载类...");
    var filter = "";  // 可改为关键字过滤，如 "vip"
    Java.enumerateLoadedClasses({
        onMatch: function (name) {
            if (name.indexOf(".") > 0 && (filter === "" || name.toLowerCase().indexOf(filter) >= 0)) {
                console.log("[CLASS] " + name);
            }
        },
        onComplete: function () { console.log("[*] 列举完成"); }
    });
});
