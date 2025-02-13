# Mantenha classes do Google Auth API
-keep class com.google.android.gms.auth.api.credentials.** { *; }

# Mantenha classes do Firebase Auth UI
-keep class com.firebase.ui.auth.** { *; }

# Evita remoção de classes importantes
-keepattributes *Annotation*
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
