# Stripe push provisioning classes are optional and not shipped with flutter_stripe.
# Tell R8 not to fail when these references can't be resolved.
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Flutter references Play Core for deferred components / split installs. We don't
# use that feature, so suppress R8's missing-class errors for it.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Flutter / plugin entry points (safety net for release minification).
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
