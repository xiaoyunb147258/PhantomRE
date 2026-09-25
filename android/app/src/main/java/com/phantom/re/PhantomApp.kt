package com.phantom.re

import android.app.Application
import android.content.Context
import android.util.Log
import top.niunaijun.blackbox.BlackBoxCore

class PhantomApp : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        try {
            BlackBoxCore.get().closeCodeInit()
            BlackBoxCore.get().onBeforeMainApplicationAttach(this, base)
            BlackBoxCore.get().onAfterMainApplicationAttach(this, base)
            Log.i("PhantomApp", "BlackBox engine attached")
        } catch (e: Exception) {
            Log.e("PhantomApp", "BlackBox attach failed: " + e.message)
        }
    }

    override fun onCreate() {
        super.onCreate()
        try {
            Log.i("PhantomApp", "PhantomApp onCreate")
        } catch (e: Exception) {
            Log.e("PhantomApp", "onCreate error: " + e.message)
        }
    }
}
