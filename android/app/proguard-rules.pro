# Keep class names and methods intact for reflection (e.g., Gson, Retrofit, etc.)
# These libraries rely on reflection to find and instantiate classes.

# Keep all classes in your package intact (adjust the package name)
-keep class com.yourpackage.** { *; }

# Gson requires these rules for serialization and deserialization
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Retrofit and OkHttp (if used) may require this rule for reflection
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep data model classes used with Parcelable or Serializable
-keep class com.yourpackage.models.** implements android.os.Parcelable { *; }
-keep class com.yourpackage.models.** implements java.io.Serializable { *; }

# Keep all classes from libraries like Room or SQLite intact if using
# Room Database
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

# If you're using Dagger or dependency injection, keep the components and modules
# Dagger
-keep class dagger.** { *; }
-keep interface dagger.** { *; }
-dontwarn dagger.**

# Keep Retrofit service interfaces
-keep interface com.yourpackage.api.** { *; }

# Keep WebView classes intact if you're using WebView
-keep class android.webkit.WebView { *; }

# Keep all classes used with Firebase (e.g., Firestore, FirebaseAuth, etc.)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# If you use any libraries for logging like Timber, keep those intact
-keep class timber.log.** { *; }
-dontwarn timber.log.**

# Keep class used in ViewBinding (if enabled)
-keep class **Binding { *; }

# Keep ViewModel and LiveData classes (if you're using Android Architecture Components)
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Keep all classes in third-party libraries (if you're using any other external libraries)
# Make sure to check the library documentation for specific rules if needed
-keep class com.thirdparty.** { *; }

# Keep the activity, service, and broadcast receiver classes (if needed)
-keep class com.yourpackage.**.Activity { *; }
-keep class com.yourpackage.**.Service { *; }
-keep class com.yourpackage.**.BroadcastReceiver { *; }

# If using FirebaseMessaging, keep necessary classes for notifications
-keep class com.google.firebase.messaging.** { *; }

# Retain all annotations in your app (useful if you're using libraries like Gson, Retrofit, etc.)
-keep @interface com.yourpackage.annotations.** { *; }

# Retain any class or method annotated with @Keep
-keep @com.google.firebase.database.IgnoreExtraProperties class * { *; }

# Add other necessary rules for libraries you're using as needed

# TensorFlow Lite GPU Delegate - Ignore missing class warning
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
