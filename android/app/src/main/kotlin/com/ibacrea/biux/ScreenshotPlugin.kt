package com.ibacrea.biux

import android.app.Activity
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ScreenshotPlugin {
    companion object {
        private const val CHANNEL = "com.biux.app/screenshot"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "enableScreenshotPrevention" -> {
                            activity.window.setFlags(
                                WindowManager.LayoutParams.FLAG_SECURE,
                                WindowManager.LayoutParams.FLAG_SECURE
                            )
                            result.success(true)
                        }
                        "disableScreenshotPrevention" -> {
                            activity.window.clearFlags(
                                WindowManager.LayoutParams.FLAG_SECURE
                            )
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                }
        }
    }
}
