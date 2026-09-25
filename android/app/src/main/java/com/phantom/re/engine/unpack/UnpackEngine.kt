package com.phantom.re.engine.unpack

import android.content.Context
import top.niunaijun.blackbox.BlackBoxCore
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile

/**
 * 脱壳引擎（功能 5-9）
 *  5 动态脱壳  6 静态脱壳  7 整体加固脱壳  8 so脱壳  9 dex导出
 */
object UnpackEngine {
    private const val USER_ID = 0

    /** 6 静态脱壳：直接解压 APK 中的 dex */
    fun staticUnpack(ctx: Context, apkPath: String, outDir: String): String {
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        val apk = File(apkPath)
        if (!apk.exists()) return "ERR: APK 不存在: $apkPath"
        val sb = StringBuilder("== 静态脱壳 ==\n"); var n = 0
        try {
            val zf = ZipFile(apk)
            for (e in zf.entries()) {
                if (e.name.endsWith(".dex")) {
                    val dst = File(out, File(e.name).name)
                    zf.getInputStream(e).use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                    sb.append("  抽出: ${dst.name} (${dst.length()} bytes)\n"); n++
                }
            }
            zf.close()
        } catch (ex: Exception) { sb.append("  ERR: ${ex.message}\n") }
        sb.append(if (n == 0) "未找到明文 dex（可能被加固，请用动态脱壳）" else "完成，共 $n 个 dex")
        return sb.toString()
    }

    /** 5 动态脱壳 */
    fun dynamicUnpack(ctx: Context, apkPath: String, outDir: String): String {
        val sb = StringBuilder("== 动态脱壳 ==\n")
        sb.append("[1/3] 安装到沙盒...\n"); sb.append("  ${install(apkPath)}\n")
        sb.append("[2/3] 沙盒启动...\n"); sb.append("  ${launch(apkPath)}\n")
        Thread.sleep(4000)
        sb.append("[3/3] dump dex...\n"); sb.append(dumpDex(ctx, outDir))
        return sb.toString()
    }

    /** 7 整体加固脱壳 */
    fun packedUnpack(ctx: Context, apkPath: String, outDir: String): String {
        val sb = StringBuilder("== 整体加固脱壳 ==\n")
        sb.append(dynamicUnpack(ctx, apkPath, outDir))
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        var extra = 0
        for (base in listOf(File(ctx.dataDir, "BlackBox"), File(ctx.dataDir, "virtual"))) {
            if (!base.exists()) continue
            base.walkTopDown().forEach { f ->
                try {
                    if (f.isFile && (f.name.endsWith(".vdex") || f.name.endsWith(".odex") || f.name.endsWith(".oat"))) {
                        val dst = File(out, "packed_${extra}_${f.name}")
                        f.inputStream().use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                        extra++
                    }
                } catch (_: Exception) {}
            }
        }
        sb.append("额外 dump vdex/odex/oat: $extra 个\n")
        return sb.toString()
    }

    /** 8 so脱壳 */
    fun soUnpack(ctx: Context, apkPath: String, outDir: String): String {
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        val sb = StringBuilder("== so 提取 ==\n"); var n = 0
        try {
            val zf = ZipFile(File(apkPath))
            for (e in zf.entries()) {
                if (e.name.startsWith("lib/") && e.name.endsWith(".so")) {
                    val sub = File(out, "so"); if (!sub.exists()) sub.mkdirs()
                    val dst = File(sub, File(e.name).name)
                    zf.getInputStream(e).use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                    sb.append("  ${dst.name} (${dst.length()} bytes)\n"); n++
                }
            }
            zf.close()
        } catch (ex: Exception) { sb.append("  ERR: ${ex.message}\n") }
        sb.append("完成，共 $n 个 so")
        return sb.toString()
    }

    /** 总入口 */
    fun unpack(ctx: Context, apkPath: String, mode: String, outDir: String): String =
        when {
            mode.contains("静态") -> staticUnpack(ctx, apkPath, outDir)
            mode.contains("整体") -> packedUnpack(ctx, apkPath, outDir)
            mode.contains("so") -> soUnpack(ctx, apkPath, outDir)
            else -> dynamicUnpack(ctx, apkPath, outDir)
        }

    // -------- 沙盒底座 --------
    fun install(apkPath: String): String = try {
        val res = BlackBoxCore.get().installPackageAsUser(apkPath, USER_ID)
        if (res.success && res.packageName != null) "安装成功: ${res.packageName}"
        else "ERR: 安装失败 ${res.msg ?: "未知"}"
    } catch (e: Exception) { "ERR: 安装异常 ${e.message}" }

    fun launch(apkPath: String): String = try {
        val res = BlackBoxCore.get().installPackageAsUser(apkPath, USER_ID)
        val pkg = res.packageName ?: return "ERR: 无包名"
        if (BlackBoxCore.get().launchApk(pkg, USER_ID)) "已启动 $pkg" else "ERR: 启动失败"
    } catch (e: Exception) { "ERR: 启动异常 ${e.message}" }

    fun dumpDex(ctx: Context, outDir: String): String {
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        val sb = StringBuilder(); var count = 0
        val dirs = listOf(File(ctx.dataDir, "BlackBox"), File(ctx.filesDir, "BlackBox"), ctx.cacheDir)
        for (dir in dirs) {
            if (!dir.exists()) continue
            dir.walkTopDown().forEach { f ->
                try {
                    if (f.isFile && f.name.endsWith(".dex")) {
                        val dst = File(out, "dump_${count}_${f.name}")
                        f.inputStream().use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                        sb.append("  ${dst.name} (${dst.length()} bytes)\n"); count++
                    }
                } catch (_: Exception) {}
            }
        }
        if (count == 0) return "未发现已落地 dex（可能内存加载，需 Frida 动态 dump）\n"
        return "导出 $count 个 dex -> $outDir\n" + sb
    }
}
