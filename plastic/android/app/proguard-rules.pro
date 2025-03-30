# Preserve Razorpay classes
-keep class com.razorpay.** { *; }

# Preserve Google Play Core Split Install classes
-keep class com.google.android.play.** { *; }

# Preserve Google Pay-related classes (required for Razorpay GPay)
-keep class com.google.android.apps.nbu.paisa.inapp.** { *; }

# Suppress warnings for missing classes
-dontwarn com.google.android.play.**
-dontwarn com.google.android.apps.nbu.paisa.inapp.**
