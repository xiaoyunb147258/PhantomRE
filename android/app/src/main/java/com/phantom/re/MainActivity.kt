package com.phantom.re

import android.os.Environment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.re/native"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            top.niunaijun.blackbox.BlackBoxCore.get().onBeforeMainActivityOnCreate(this)
            top.niunaijun.blackbox.BlackBoxCore.get().onAfterMainActivityOnCreate(this)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "blackbox activity hook: " + e.message)
        }
    }

    /** 脱壳输出目录：/sdcard/Download/PhantomRE_unpack */
    private fun outDir(): String {
        val d = File(Environment.getExternalStorageDirectory(), "Download/PhantomRE_unpack")
        if (!d.exists()) d.mkdirs()
        return d.absolutePath
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val a = call.arguments as? Map<*, *> ?: mapOf<String, Any>()
                val apk = a["apk_path"] as? String ?: ""
                when (call.method) {
                    "ping" -> result.success("pong from PhantomRE native")
                    "getDeviceInfo" -> result.success(deviceInfo())
                    "checkRoot" -> result.success(isRooted())
                    "runShell" -> result.success(runShell(a["cmd"] as? String ?: ""))
                    "installApk" -> result.success(installApk(a["path"] as? String ?: ""))

                    // ==== 沙盒运行（BlackBox 引擎） ====
                    "sandboxRun" -> result.success(sandboxRun(apk))

                    // ==== 一键脱壳（BlackBox 沙盒 + dex dump） ====
                    "unpack" -> result.success(DexDumper.oneClickUnpack(this, apk, outDir()))
                    "oneClickRepair" -> result.success(DexDumper.oneClickUnpack(this, apk, outDir()))

                    // 其余内核能力：占位（后续轮次接入）
                    "decompile" -> result.success(kernel("decompile", a["target"], a["type"]))
                    "searchCode" -> result.success(kernel("search", a["keyword"]))
                    "runHook" -> result.success(kernel("hook", a["package"]))
                    "bypassSignature" -> result.success(kernel("bypass_sig", apk))
                    "bypassDetection" -> result.success(kernel("bypass_det", a["types"]))
                    "decryptResources" -> result.success(kernel("decrypt", apk, a["target"]))
                    "captureTraffic" -> result.success(kernel("capture", a["action"]))

                    else -> result.notImplemented()
                }
            }
    }

    /** 装入沙盒并启动 */
    private fun sandboxRun(apk: String): String {
        if (apk.isEmpty()) return "ERR: 未提供 APK 路径"
        val sb = StringBuilder()
        val pkg = DexDumper.installToSandbox(this, apk)
        sb.append("安装: $pkg\n")
        if (!pkg.startsWith("ERR")) {
            val r = DexDumper.launchInSandbox(pkg)
            sb.append("启动: $r\n")
            sb.append("包名: $pkg\n")
        }
        return sb.toString()
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
        return paths.any { File(it).exists() }
    }

    private fun runShell(cmd: String): String = try {
        val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", cmd))
        p.inputStream.bufferedReader().readText()
    } catch (e: Exception) { "ERR: ${e.message}" }

    private fun installApk(path: String): String = try {
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
        intent.setDataAndType(android.net.Uri.fromFile(File(path)),
            "application/vnd.android.package-archive")
        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        "installer_launched"
    } catch (e: Exception) { "ERR: ${e.message}" }

    private fun kernel(tag: String, vararg args: Any?): String =
        "[OK] $tag 指令已接收；内核接入后返回真实结果"
}
