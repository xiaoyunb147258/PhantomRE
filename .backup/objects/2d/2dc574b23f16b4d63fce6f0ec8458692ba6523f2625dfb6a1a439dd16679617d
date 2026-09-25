package com.phantom.re

import android.content.Context
import android.util.Log
import top.niunaijun.blackbox.BlackBoxCore
import java.io.File
import java.io.FileOutputStream

/**
 * 脱壳引擎（一键脱壳）：
 * 1. 把目标 APK 安装进 BlackBox 沙盒
 * 2. 启动目标 App（触发真实 dex 加载）
 * 3. 扫描沙盒数据目录，dump 出所有 dex 到输出目录
 *
 * 说明：对大多数软件，一键即可脱出完整 dex；
 * 强加固（三代壳）可能需要 AI 分析 + 动态 Hook 配合。
 */
object DexDumper {
    private const val TAG = "DexDumper"
    private const val USER_ID = 0

    /** 安装 APK 到沙盒，返回包名 */
    fun installToSandbox(ctx: Context, apkPath: String): String {
        val core = BlackBoxCore.get()
        val file = File(apkPath)
        if (!file.exists()) return "ERR: APK 不存在: $apkPath"
        return try {
            val res = core.installPackageAsUser(apkPath, USER_ID)
            Log.i(TAG, "install success=${res.success} pkg=${res.packageName} msg=${res.msg}")
            if (res.success && res.packageName != null) res.packageName
            else "ERR: 安装失败 " + (res.msg ?: "未知")
        } catch (e: Exception) {
            Log.e(TAG, "install failed", e)
            "ERR: 安装失败 " + e.message
        }
    }

    /** 在沙盒内启动目标 App */
    fun launchInSandbox(pkgName: String): String {
        return try {
            val ok = BlackBoxCore.get().launchApk(pkgName, USER_ID)
            if (ok) "OK: 已启动 $pkgName" else "ERR: 启动失败 $pkgName"
        } catch (e: Exception) {
            Log.e(TAG, "launch failed", e)
            "ERR: 启动异常 " + e.message
        }
    }

    /** Dump 沙盒内所有已落地的 dex 到 outDir */
    fun dumpDex(ctx: Context, outDir: String): String {
        val out = File(outDir)
        if (!out.exists()) out.mkdirs()
        val sb = StringBuilder()
        var count = 0

        val candidates = mutableListOf<File>()
        candidates.add(File(ctx.dataDir, "BlackBox"))
        candidates.add(File(ctx.filesDir, "BlackBox"))
        try {
            candidates.add(File("/data/data/${ctx.packageName}"))
            candidates.add(File("/data/user/0/${ctx.packageName}"))
        } catch (_: Exception) {}
        candidates.add(ctx.cacheDir)

        for (dir in candidates) {
            if (!dir.exists()) continue
            dir.walkTopDown().forEach { f ->
                try {
                    if (f.isFile && (f.name.endsWith(".dex") || f.name.contains("base.apk"))) {
                        if (f.name.contains("base.apk")) {
                            count += extractDexFromApk(f, out, sb)
                        } else {
                            val dst = File(out, "dump_${count}_${f.name}")
                            f.inputStream().use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                            sb.append("  导出: ${dst.name} (${dst.length()} bytes)\n")
                            count++
                        }
                    }
                } catch (e: Exception) { /* skip */ }
            }
        }
        if (count == 0) {
            return "警告: 未找到已 dump 的 dex。请先『装入沙盒』并『启动』目标 App，让它在沙盒内跑起来后再脱壳。"
        }
        sb.insert(0, "发现并导出 $count 个文件 -> $outDir\n")
        return sb.toString()
    }

    private fun extractDexFromApk(apk: File, out: File, sb: StringBuilder): Int {
        var n = 0
        return try {
            val zf = java.util.zip.ZipFile(apk)
            for (e in zf.entries()) {
                if (e.name.endsWith(".dex")) {
                    val dst = File(out, "apk_${n}_${File(e.name).name}")
                    zf.getInputStream(e).use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                    sb.append("  从apk抽取: ${dst.name} (${dst.length()} bytes)\n")
                    n++
                }
            }
            zf.close()
            n
        } catch (e: Exception) { 0 }
    }

    /** 一键：安装 + 启动 + dump */
    fun oneClickUnpack(ctx: Context, apkPath: String, outDir: String): String {
        val sb = StringBuilder()
        sb.append("== 脱壳开始 ==\n")
        sb.append("[1/3] 安装到沙盒...\n")
        val pkg = installToSandbox(ctx, apkPath)
        sb.append("  结果: $pkg\n")
        if (pkg.startsWith("ERR")) return sb.toString()
        sb.append("[2/3] 在沙盒启动...\n")
        val launched = launchInSandbox(pkg)
        sb.append("  结果: $launched\n")
        sb.append("[3/3] dump dex...\n")
        Thread.sleep(3000)
        sb.append(dumpDex(ctx, outDir))
        sb.append("== 脱壳结束 ==")
        return sb.toString()
    }
}
