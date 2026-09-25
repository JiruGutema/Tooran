# Tooran release (R8) keep rules.
# Flutter's own rules (flutter_proguard_rules.pro) are added by the Flutter Gradle plugin.

## flutter_local_notifications
# v19+ gets Gson's consumer rules automatically, but scheduled notifications are
# (de)serialised with Gson + reflection, so keep the plugin's model classes and
# generic signatures explicitly to be safe.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**

## home_widget: widget provider + background receiver are referenced from the manifest
## (kept by aapt), the WorkManager worker is instantiated reflectively.
-keep class es.antonborri.home_widget.** { *; }
-keep class io.github.jirugutema.tooran.TooranWidgetProvider { *; }

## Play Core (referenced by the Flutter embedding for deferred components; not used).
-dontwarn com.google.android.play.core.**
