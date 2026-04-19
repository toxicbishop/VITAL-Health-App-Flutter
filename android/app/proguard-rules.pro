# Flutter-specific ProGuard/R8 rules
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep annotation classes
-keepattributes *Annotation*

# Keep Google Sign-In classes
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep Floor/SQLite classes
-keep class androidx.sqlite.** { *; }

# Suppress warnings for third-party libraries
-dontwarn com.google.android.play.core.**
-dontwarn com.google.errorprone.annotations.**
