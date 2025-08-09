package com.jiren.tooran

import androidx.multidex.MultiDexApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class MainApplication : MultiDexApplication() {
    
    override fun onCreate() {
        super.onCreate()
        
        // Pre-warm Flutter engine for better notification performance
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("main_engine", flutterEngine)
    }
}