-keep class io.flutter.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class kotlin.Metadata { *; }
-keep class android.support.v4.media.session.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
