package com.phantom.re

import android.app.Application
import android.content.Context
import android.util.Log
import top.niunaijun.blackbox.BlackBoxCore
import top.niunaijun.blackbox.app.configuration.ClientConfiguration

/**
 * 宿主 Application —— 严格按 BlackBox 官方 demo (App.kt) 的顺序初始化。
 * 顺序：closeCodeInit -> onBeforeMainApplicationAttach
 *       -> doAttachBaseContext(base, ClientConfiguration)
 *       -> onAfterMainApplicationAttach
 *       -> doCreate()
 */
class PhantomApp : Application() {

    private lateinit var ctx: Context

    override fun attachBaseContext(base: Context?) {
        try {
            super.attachBaseContext(base)
            if (base == null) return
            ctx = base
            try { BlackBoxCore.get().closeCodeInit() } catch (e: Exception) { Log.e("PhantomApp", "" + e.message) }
            try { BlackBoxCore.get().onBeforeMainApplicationAttach(this, base) } catch (e: Exception) { Log.e("PhantomApp", "" + e.message) }
            try {
                BlackBoxCore.get().doAttachBaseContext(base, object : ClientConfiguration() {
                    override fun getHostPackageName(): String = packageName
                    override fun isHideRoot(): Boolean = true
                    override fun isEnableDaemonService(): Boolean = true
                    override fun isUseVpnNetwork(): Boolean = false
                    override fun isDisableFlagSecure(): Boolean = true
                })
            } catch (e: Exception) { Log.e("PhantomApp", "attach: " + e.message) }
            try { BlackBoxCore.get().onAfterMainApplicationAttach(this, base) } catch (e: Exception) { Log.e("PhantomApp", "" + e.message) }
            Log.i("PhantomApp", "attachBaseContext done")
        } catch (e: Exception) {
            Log.e("PhantomApp", "critical: " + e.message)
        }
    }

    override fun onCreate() {
        try {
            super.onCreate()
            BlackBoxCore.get().doCreate()
            Log.i("PhantomApp", "doCreate done")
        } catch (e: Exception) {
            Log.e("PhantomApp", "doCreate: " + e.message)
        }
    }
}
