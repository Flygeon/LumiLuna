package com.flygeon.lumiluna

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lumiluna/system_theme")
            .setMethodCallHandler { call, result ->
                if (call.method == "getSeedColor") {
                    val id = resources.getIdentifier("system_accent1_500", "color", "android")
                    if (id == 0) {
                        result.success(null)
                    } else {
                        result.success(resources.getColor(id, theme))
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
