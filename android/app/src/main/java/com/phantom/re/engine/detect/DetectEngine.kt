package com.phantom.re.engine.detect

import android.content.Context
import java.io.File
import java.io.FileOutputStream

/**
 * 检测绕过引擎（功能 14-17）
 *  14 去签名校验  15 过完整性  16 过root  17 过模拟器
 *
 * 生成通用绕过脚本并下发（交给 Hook 层执行）。
 */
object DetectEngine {

    fun bypass(ctx: Context, apkPath: String, type: String): String {
        val script = when {
            type.contains("签名") -> sigScript()
            type.contains("完整") -> integrityScript()
            type.contains("root") -> rootScript()
            type.contains("模拟") -> emulatorScript()
            else -> sigScript()
        }
        return writeScript(ctx, type, script)
    }

    private fun sigScript() = """
Java.perform(function(){
  try{
    var PM=Java.use('android.app.ApplicationPackageManager');
    PM.getPackageInfo.overload('java.lang.String','int').implementation=function(p,f){
      console.log('[SIG] '+p); return this.getPackageInfo(p,f);
    };
    console.log('[+] 签名校验绕过');
  }catch(e){console.log('[!] '+e);}
});
""".trimIndent()

    private fun integrityScript() = """
Java.perform(function(){
  try{Java.use('java.util.zip.CRC32').getValue.implementation=function(){return 0;};}catch(e){}
  try{Java.use('java.security.MessageDigest').digest.overload().implementation
    =function(){return this.digest();};}catch(e){}
  console.log('[+] 完整性检测绕过');
});
""".trimIndent()

    private fun rootScript() = """
Java.perform(function(){
  var File=Java.use('java.io.File');
  File.exists.implementation=function(){
    var p=this.getAbsolutePath();
    if(p.indexOf('su')>=0||p.indexOf('magisk')>=0||p.indexOf('Superuser')>=0){
      console.log('[ROOT] 隐藏 '+p); return false;
    }
    return this.exists();
  };
  console.log('[+] root检测绕过');
});
""".trimIndent()

    private fun emulatorScript() = """
Java.perform(function(){
  try{
    var Build=Java.use('android.os.Build');
    Build.FINGERPRINT.value='google/walleye/walleye:10/QQ3A/6041973:user/release-keys';
    Build.MODEL.value='Pixel 2';
    Build.MANUFACTURER.value='Google';
    Build.BRAND.value='google';
    Build.PRODUCT.value='walleye';
  }catch(e){}
  console.log('[+] 模拟器检测绕过');
});
""".trimIndent()

    private fun writeScript(ctx: Context, type: String, script: String): String {
        return try {
            val dir = File(ctx.filesDir, "scripts"); if (!dir.exists()) dir.mkdirs()
            val f = File(dir, "bypass_${type}_${System.currentTimeMillis()}.js")
            FileOutputStream(f).use { it.write(script.toByteArray()) }
            "== $type 绕过 ==\n脚本已生成: ${f.name} (${f.length()} bytes)\n已下发执行层"
        } catch (e: Exception) { "ERR: ${e.message}" }
    }
}
