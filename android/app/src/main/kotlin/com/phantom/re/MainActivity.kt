package com.phantom.re

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.re/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "ping" -> result.success("pong from PhantomRE native")
                    "getDeviceInfo" -> {
                        val info = mapOf(
                            "model" to android.os.Build.MODEL,
                            "android" to android.os.Build.VERSION.RELEASE,
                            "sdk" to android.os.Build.VERSION.SDK_INT,
                            "abi" to android.os.Build.SUPPORTED_ABIS.joinToString(",")
                        )
                        result.success(info)
                    }
                    "checkRoot" -> result.success(isRooted())
                    "runShell" -> {
                        val cmd = call.argument<String>("cmd") ?: ""
                        result.success(runShell(cmd))
                    }
                    "installApk" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(installApk(path))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isRooted(): Boolean {
        val paths = arrayOf("/system/app/Superuser.apk", "/sbin/su", "/system/bin/su",
            "/system/xbin/su", "/data/local/xbin/su", "/data/local/bin/su")
        return paths.any { java.io.File(it).exists() }
    }

    private fun runShell(cmd: String): String {
        return try {
            val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", cmd))
            p.inputStream.bufferedReader().readText()
        } catch (e: Exception) { "ERR: ${e.message}" }
    }

    private fun installApk(path: String): String {
        return try {
            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
            intent.setDataAndType(
                android.net.Uri.fromFile(java.io.File(path)),
                "application/vnd.android.package-archive"
            )
            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            "installer_launched"
        } catch (e: Exception) { "ERR: ${e.message}" }
    }
}
