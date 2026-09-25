package com.phantom.re

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.re/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val a = call.arguments as? Map<*, *> ?: mapOf<String, Any>()
                when (call.method) {
                    "ping" -> result.success("pong from PhantomRE native")
                    "getDeviceInfo" -> result.success(deviceInfo())
                    "checkRoot" -> result.success(isRooted())
                    "runShell" -> result.success(runShell(a["cmd"] as? String ?: ""))
                    "installApk" -> result.success(installApk(a["path"] as? String ?: ""))

                    // ==== 内核能力（内核接入前返回占位，保证不崩溃） ====
                    "sandboxRun" -> result.success(kernel("sandbox", a["apk_path"]))
                    "unpack" -> result.success(kernel("unpack", a["apk_path"], a["mode"]))
                    "decompile" -> result.success(kernel("decompile", a["target"], a["type"]))
                    "searchCode" -> result.success(kernel("search", a["keyword"]))
                    "runHook" -> result.success(kernel("hook", a["package"]))
                    "bypassSignature" -> result.success(kernel("bypass_sig", a["apk_path"]))
                    "bypassDetection" -> result.success(kernel("bypass_det", a["types"]))
                    "decryptResources" -> result.success(kernel("decrypt", a["apk_path"], a["target"]))
                    "captureTraffic" -> result.success(kernel("capture", a["action"]))
                    "oneClickRepair" -> result.success(kernel("repair", a["apk_path"]))

                    else -> result.notImplemented()
                }
            }
    }

    private fun deviceInfo(): Map<String, Any> = mapOf(
        "model" to android.os.Build.MODEL,
        "android" to android.os.Build.VERSION.RELEASE,
        "sdk" to android.os.Build.VERSION.SDK_INT,
        "abi" to android.os.Build.SUPPORTED_ABIS.joinToString(",")
    )

    private fun isRooted(): Boolean {
        val paths = arrayOf("/system/app/Superuser.apk", "/sbin/su", "/system/bin/su",
            "/system/xbin/su", "/data/local/xbin/su", "/data/local/bin/su")
        return paths.any { java.io.File(it).exists() }
    }

    private fun runShell(cmd: String): String = try {
        val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", cmd))
        p.inputStream.bufferedReader().readText()
    } catch (e: Exception) { "ERR: ${e.message}" }

    private fun installApk(path: String): String = try {
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
        intent.setDataAndType(android.net.Uri.fromFile(java.io.File(path)),
            "application/vnd.android.package-archive")
        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        "installer_launched"
    } catch (e: Exception) { "ERR: ${e.message}" }

    /// 内核占位：真实内核接入后替换此实现
    private fun kernel(tag: String, vararg args: Any?): String {
        return "[OK] $tag 指令已接收 args=${args.joinToString(",")}；内核接入后此处返回真实结果"
    }
}
