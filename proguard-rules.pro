# Keep ML Kit pose detection classes (reflection-based model loading)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_pose** { *; }

# Keep TensorFlow Lite classes (if the optional custom model is used)
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep Hive generated adapters
-keep class * extends com.google.gson.TypeAdapter
-keepattributes *Annotation*
