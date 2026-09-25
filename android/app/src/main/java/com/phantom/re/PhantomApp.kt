package com.phantom.re

import android.app.Application
import android.content.Context
import android.util.Log
import top.niunaijun.blackbox.BlackBoxCore
import top.niunaijun.blackbox.app.configuration.ClientConfiguration

/**
 * 宿主 Application —— 正确初始化 BlackBox 虚拟化引擎。
 *
 * 关键：必须在 attachBaseContext 里调用 doAttachBaseContext(context, ClientConfiguration)，
 * 否则引擎的 ClientConfiguration 为 null，一用 installPackageAsUser 就报
 * "getHostPackageName() on a null object reference"。
 */
class PhantomApp : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        try {
            BlackBoxCore.get().doAttachBaseContext(base, object : ClientConfiguration() {
                override fun getHostPackageName(): String = packageName
                override fun isHideRoot(): Boolean = true
                override fun isEnableDaemonService(): Boolean = true
                override fun isUseVpnNetwork(): Boolean = false
                override fun isDisableFlagSecure(): Boolean = true
            })
            Log.i("PhantomApp", "BlackBox doAttachBaseContext OK")
        } catch (e: Exception) {
            Log.e("PhantomApp", "attach failed: " + e.message)
        }
    }

    override fun onCreate() {
        super.onCreate()
        try {
            BlackBoxCore.get().doCreate()
            Log.i("PhantomApp", "BlackBox doCreate OK")
        } catch (e: Exception) {
            Log.e("PhantomApp", "doCreate failed: " + e.message)
        }
    }
}
