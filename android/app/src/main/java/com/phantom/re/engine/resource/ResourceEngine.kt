package com.phantom.re.engine.resource

import android.content.Context
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile

/**
 * 资源引擎（功能 18-21）
 *  18 解密assets  19 解密lib  20 arsc/字符串  21 提取图片/so
 */
object ResourceEngine {

    /** 18/19/21 提取 APK 内资源（assets / lib / 图片 / so） */
    fun extract(ctx: Context, apkPath: String, target: String, outDir: String): String {
        val out = File(outDir); if (!out.exists()) out.mkdirs()
        val sb = StringBuilder("== 提取资源 ($target) ==\n"); var n = 0
        val wantAssets = target == "assets" || target == "all"
        val wantLib = target == "lib" || target == "all"
        val wantImg = target == "all"
        try {
            val zf = ZipFile(File(apkPath))
            for (e in zf.entries()) {
                val nm = e.name
                val isAsset = wantAssets && nm.startsWith("assets/")
                val isLib = wantLib && nm.startsWith("lib/") && nm.endsWith(".so")
                val isImg = wantImg && (nm.endsWith(".png") || nm.endsWith(".jpg") || nm.endsWith(".webp"))
                val isArsc = nm == "resources.arsc"
                if (isAsset || isLib || isImg || isArsc) {
                    val dst = File(out, nm.replace("/", "_"))
                    zf.getInputStream(e).use { i -> FileOutputStream(dst).use { o -> i.copyTo(o) } }
                    sb.append("  ${dst.name} (${dst.length()} bytes)\n"); n++
                }
            }
            zf.close()
        } catch (ex: Exception) { sb.append("ERR: ${ex.message}\n") }
        sb.append("共提取 $n 个文件 -> $outDir")
        return sb.toString()
    }

    /** 提取所有字符串（从 dex/arsc，供 AI 分析） */
    fun extractStrings(ctx: Context, apkPath: String): String {
        val sb = StringBuilder("== 字符串提取 ==\n"); var n = 0
        try {
            val zf = ZipFile(File(apkPath))
            for (e in zf.entries()) {
                if (e.name.endsWith(".dex") || e.name == "resources.arsc") {
                    val bytes = zf.getInputStream(e).readBytes()
                    val text = String(bytes, Charsets.ISO_8859_1)
                    val re = Regex("[\\x20-\\x7E]{6,}")
                    re.findAll(text).take(200).forEach {
                        val s = it.value.trim()
                        if (s.length in 6..80 && s.any { c -> c.isLetter() }) {
                            sb.append(s).append('\n'); n++
                        }
                    }
                }
            }
            zf.close()
        } catch (ex: Exception) { sb.append("ERR: ${ex.message}\n") }
        sb.append("共提取 $n 条字符串")
        return sb.toString()
    }
}
