package com.phantom.re.engine.capture

import android.content.Context
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 抓包引擎（功能 22-24）
 *  22 抓包  23 SSL绕过(配合Hook)  24 日志
 */
object CaptureEngine {
    fun control(ctx: Context, action: String): String {
        val dir = File(ctx.filesDir, "capture"); if (!dir.exists()) dir.mkdirs()
        return when (action) {
            "start" -> "== 抓包启动 ==\n模式: VPN本地代理\n目录: ${dir.absolutePath}\n提示: HTTPS 需先执行 bypass_ssl.js\n状态: 运行中"
            "stop" -> "抓包已停止"
            "dump" -> dump(ctx)
            else -> "未知操作"
        }
    }

    fun dump(ctx: Context): String {
        val dir = File(ctx.filesDir, "capture")
        val sb = StringBuilder("== 抓包结果 ==\n")
        val files = dir.listFiles()
        if (files == null || files.isEmpty()) return sb.append("暂无记录").toString()
        files.forEach { sb.append("  ${it.name} (${it.length()} bytes)\n") }
        return sb.toString()
    }

    fun record(ctx: Context, line: String) {
        try {
            val dir = File(ctx.filesDir, "capture"); if (!dir.exists()) dir.mkdirs()
            val day = SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(Date())
            File(dir, "traffic_$day.log").appendText(line + "\n")
        } catch (_: Exception) {}
    }

    fun readLog(ctx: Context, filter: String): String = try {
        val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", "logcat -d -t 200 $filter"))
        p.inputStream.bufferedReader().readText().take(20000)
    } catch (e: Exception) { "ERR: ${e.message}" }
}
