package com.phantom.re

import android.os.Environment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.phantom.re.engine.capture.CaptureEngine
import com.phantom.re.engine.decompile.DecompileEngine
import com.phantom.re.engine.detect.DetectEngine
import com.phantom.re.engine.hook.HookEngine
import com.phantom.re.engine.resource.ResourceEngine
import com.phantom.re.engine.unpack.UnpackEngine
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.re/native"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            top.niunaijun.blackbox.BlackBoxCore.get().onBeforeMainActivityOnCreate(this)
            top.niunaijun.blackbox.BlackBoxCore.get().onAfterMainActivityOnCreate(this)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "blackbox hook: " + e.message)
        }
        requestStoragePermission()
    }

    /** 申请存储权限（Android 11+ 需 MANAGE_EXTERNAL_STORAGE 才能写 /sdcard/Download） */
    private fun requestStoragePermission() {
        try {
            if (android.os.Build.VERSION.SDK_INT >= 30) {
                if (!android.os.Environment.isExternalStorageManager()) {
                    val intent = android.content.Intent(
                        android.provider.Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                    intent.data = android.net.Uri.parse("package:$packageName")
                    startActivity(intent)
                }
            } else {
                if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                    requestPermissions(arrayOf(
                        android.Manifest.permission.READ_EXTERNAL_STORAGE,
                        android.Manifest.permission.WRITE_EXTERNAL_STORAGE), 1001)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "perm: " + e.message)
        }
    }

    private fun outDir(sub: String): String {
        val d = File(Environment.getExternalStorageDirectory(), "Download/PhantomRE/$sub")
        if (!d.exists()) d.mkdirs()
        return d.absolutePath
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val a = call.arguments as? Map<*, *> ?: mapOf<String, Any>()
                val apk = a["apk_path"] as? String ?: ""
                try {
                    when (call.method) {
                        "ping" -> result.success("pong")
                        "getDeviceInfo" -> result.success(deviceInfo())
                        "checkRoot" -> result.success(isRooted())
                        "runShell" -> result.success(runShell(a["cmd"] as? String ?: ""))
                        "installApk" -> result.success(installApk(a["path"] as? String ?: ""))

                        "sandboxRun" -> result.success(sandboxRun(apk))

                        "unpack" -> result.success(
                            UnpackEngine.unpack(this, apk, a["mode"] as? String ?: "动态脱壳", outDir("unpack")))

                        "oneClickRepair" -> result.success(oneClickRepair(apk))

                        "decompile" -> result.success(
                            DecompileEngine.unzipApk(this, apk, outDir("decompile")))
                        "parseManifest" -> result.success(DecompileEngine.parseManifest(this, apk))
                        "scanSensitive" -> result.success(DecompileEngine.scanSensitive(this, apk))
                        "searchCode" -> result.success(
                            DecompileEngine.searchCode(this, apk, a["keyword"] as? String ?: ""))

                        "runHook" -> result.success(
                            HookEngine.runHook(this, a["script"] as? String ?: "", a["package"] as? String ?: ""))
                        "loadHookPreset" -> result.success(
                            HookEngine.loadScript(this, a["name"] as? String ?: "hook_log"))

                        "bypassSignature" -> result.success(DetectEngine.bypass(this, apk, "签名"))
                        "bypassDetection" -> result.success(
                            DetectEngine.bypass(this, apk, a["types"] as? String ?: "root"))

                        "decryptResources" -> result.success(
                            ResourceEngine.extract(this, apk, a["target"] as? String ?: "all", outDir("resource")))
                        "extractStrings" -> result.success(ResourceEngine.extractStrings(this, apk))

                        "captureTraffic" -> result.success(
                            CaptureEngine.control(this, a["action"] as? String ?: "start"))
                        "readLog" -> result.success(
                            CaptureEngine.readLog(this, a["filter"] as? String ?: ""))

                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.success("ERR: ${e.message}")
                }
            }
    }

    private fun sandboxRun(apk: String): String {
        if (apk.isEmpty()) return "ERR: 未提供 APK 路径"
        return "安装: ${UnpackEngine.install(apk)}\n启动: ${UnpackEngine.launch(apk)}\n"
    }

    private fun oneClickRepair(apk: String): String {
        val sb = StringBuilder("== 一键脱修 ==\n")
        sb.append("[1] 脱壳\n").append(UnpackEngine.dynamicUnpack(this, apk, outDir("repair/dex"))).append("\n")
        sb.append("[2] 去签名校验\n").append(DetectEngine.bypass(this, apk, "签名")).append("\n")
        sb.append("[3] 防自毁/防杀\n").append(DetectEngine.bypass(this, apk, "root")).append("\n")
        sb.append("[4] 解密 assets\n").append(ResourceEngine.extract(this, apk, "assets", outDir("repair/assets"))).append("\n")
        sb.append("[5] 解密 lib\n").append(ResourceEngine.extract(this, apk, "lib", outDir("repair/lib"))).append("\n")
        sb.append("== 完成 ==")
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
}
