# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep OkHttp classes for umeng_apm_sdk and EFS SDK
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keepclassmembers class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep specific OkHttp classes referenced by EFS SDK
-keep class okhttp3.Call { *; }
-keep class okhttp3.Callback { *; }
-keep class okhttp3.Connection { *; }
-keep class okhttp3.EventListener { *; }
-keep class okhttp3.EventListener$Factory { *; }
-keep class okhttp3.Handshake { *; }
-keep class okhttp3.Headers { *; }
-keep class okhttp3.HttpUrl { *; }
-keep class okhttp3.Interceptor { *; }
-keep class okhttp3.Interceptor$Chain { *; }
-keep class okhttp3.MediaType { *; }
-keep class okhttp3.OkHttpClient { *; }
-keep class okhttp3.OkHttpClient$Builder { *; }
-keep class okhttp3.Protocol { *; }
-keep class okhttp3.Request { *; }
-keep class okhttp3.Request$Builder { *; }
-keep class okhttp3.RequestBody { *; }
-keep class okhttp3.Response { *; }
-keep class okhttp3.Response$Builder { *; }
-keep class okhttp3.ResponseBody { *; }

# Keep EFS SDK classes
-keep class com.efs.sdk.** { *; }
-dontwarn com.efs.sdk.**

# Keep Umeng SDK classes
-keep class com.umeng.** { *; }
-dontwarn com.umeng.**
