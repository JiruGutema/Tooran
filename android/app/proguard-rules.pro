# Flutter notification plugin rules
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Timezone data
-keep class org.threeten.bp.** { *; }
-dontwarn org.threeten.bp.**

# Keep notification receivers
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.app.Service

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Google Play Core (fix for missing classes)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep notification data classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# General Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}