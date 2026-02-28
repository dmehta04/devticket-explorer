# ============================================================================
# Flutter ProGuard Rules — PUBLISH-KIT managed
# ============================================================================

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Gson / JSON serialization (if used)
-keepattributes Signature
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Firebase (if used)
-keep class com.google.firebase.** { *; }

# Google Play Services (if used)
-keep class com.google.android.gms.** { *; }

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
