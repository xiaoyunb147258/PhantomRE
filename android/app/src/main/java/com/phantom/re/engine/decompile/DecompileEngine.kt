package com.phantom.re.engine.decompile

import android.content.Context
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile

/**
 * 反编译 / 静态分析引擎（功能 25-29）
 *  25 DEX->Java(jadx)  26 APK解包  27 资源  28 Manifest解析  29 敏感信息扫描
 */
object DecompileEngine {

    /** 26 解包 APK */
    fun unzipApk(ctx: Context, apkPath: String, outDir: String): String {
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        val sb = StringBuilder("== 解包 APK ==\n"); var n = 0
        try {
            val zf = ZipFile(File(apkPath))
            for (e in zf.entries()) {
                val f = File(out, e.name)
                if (e.isDirectory) { f.mkdirs(); continue }
                f.parentFile?.mkdirs()
                zf.getInputStream(e).use { i -> FileOutputStream(f).use { o -> i.copyTo(o) } }
                n++
            }
            zf.close()
        } catch (ex: Exception) { sb.append("ERR: ${ex.message}\n") }
        sb.append("解包 $n 个文件 -> $outDir")
        return sb.toString()
    }

    /** 28 解析 AndroidManifest */
    fun parseManifest(ctx: Context, apkPath: String): String {
        val sb = StringBuilder("== AndroidManifest ==\n")
        try {
            val zf = ZipFile(File(apkPath))
            val entry = zf.getEntry("AndroidManifest.xml")
            if (entry == null) { zf.close(); return "ERR: 未找到 AndroidManifest.xml" }
            val bytes = zf.getInputStream(entry).readBytes()
            zf.close()
            if (bytes.size >= 2 && bytes[0].toInt() == 0x03 && bytes[1].toInt() == 0x00) {
                sb.append("(二进制格式，提取字符串表)\n")
                sb.append(extractStrings(bytes).take(3000))
            } else {
                sb.append(String(bytes))
            }
        } catch (e: Exception) { sb.append("ERR: ${e.message}") }
        return sb.toString()
    }

    private fun extractStrings(b: ByteArray): String {
        val sb = StringBuilder(); var i = 0
        while (i < b.size - 1) {
            val c = ((b[i].toInt() and 0xFF) or (b[i + 1].toInt() shl 8))
            if (c in 32..126) sb.append(c.toChar())
            else if (c == 0 && sb.isNotEmpty()) sb.append('\n')
            if (sb.length > 5000) break
            i += 2
        }
        return sb.toString()
    }

    /** 29 敏感信息扫描 */
    fun scanSensitive(ctx: Context, apkPath: String): String {
        val sb = StringBuilder("== 敏感信息扫描 ==\n")
        val patterns = mapOf(
            "API Key" to Regex("(?i)(api[_-]?key|apikey)[\"'\\s:=]+([A-Za-z0-9_\\-]{16,})"),
            "Secret" to Regex("(?i)(secret|token)[\"'\\s:=]+([A-Za-z0-9_\\-]{16,})"),
            "URL" to Regex("https?://[A-Za-z0-9._/\\-?=&%]{8,}"),
            "IP" to Regex("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b")
        )
        try {
            val zf = ZipFile(File(apkPath))
            for (e in zf.entries()) {
                if (!e.name.endsWith(".dex")) continue
                val text = String(zf.getInputStream(e).readBytes(), Charsets.ISO_8859_1)
                for ((name, re) in patterns) {
                    val found = re.findAll(text).take(10).toList()
                    if (found.isNotEmpty()) {
                        sb.append("\n[$name] 命中 ${found.size}+:\n")
                        found.forEach { sb.append("  ${it.value.take(120)}\n") }
                    }
                }
            }
            zf.close()
        } catch (ex: Exception) { sb.append("ERR: ${ex.message}\n") }
        if (sb.length < 30) sb.append("未发现明显敏感信息")
        return sb.toString()
    }

    /** 25 DEX->Java（内置 jadx 释放 + 说明） */
    fun dexToJava(ctx: Context, dexPath: String, outDir: String): String {
        return try {
            val jadx = File(ctx.filesDir, "jadx.jar")
            if (!jadx.exists()) {
                ctx.assets.open("tools/jadx.jar").use { i ->
                    FileOutputStream(jadx).use { o -> i.copyTo(o) }
                }
            }
            "jadx 已就绪: ${jadx.absolutePath} (${jadx.length()} bytes)\n目标: $dexPath\n输出: $outDir"
        } catch (e: Exception) {
            "jadx 未内置: ${e.message}\n替代：先解包提取 dex，再交给 AI 分析 smali"
        }
    }

    /** 搜索代码/字符串 */
    fun searchCode(ctx: Context, target: String, keyword: String): String {
        val sb = StringBuilder("== 搜索 '$keyword' ==\n"); var hits = 0
        try {
            val f = File(target)
            if (f.isFile && f.name.endsWith(".apk")) {
                val zf = ZipFile(f)
                for (e in zf.entries()) {
                    if (e.name.endsWith(".dex")) {
                        val text = String(zf.getInputStream(e).readBytes(), Charsets.ISO_8859_1)
                        var idx = text.indexOf(keyword)
                        while (idx >= 0 && hits < 30) {
                            sb.append("  [${e.name}] ...${text.substring(maxOf(0, idx - 40), minOf(text.length, idx + 40)).replace("\n", " ")}...\n")
                            hits++; idx = text.indexOf(keyword, idx + 1)
                        }
                    }
                }
                zf.close()
            } else if (f.isDirectory) {
                f.walkTopDown().forEach { file ->
                    if (file.isFile && hits < 30) {
                        try { if (file.readText().contains(keyword)) { sb.append("  ${file.name}\n"); hits++ } } catch (_: Exception) {}
                    }
                }
            }
        } catch (ex: Exception) { sb.append("ERR: ${ex.message}\n") }
        sb.append("命中 $hits 处")
        return sb.toString()
    }
}
