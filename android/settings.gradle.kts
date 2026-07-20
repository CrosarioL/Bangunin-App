pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Pinned to the newest 8.x line, not 9.x: AGP 9's "Built-in Kotlin" mode
    // conflicts with plugins that still apply their own Kotlin Gradle Plugin
    // (most of the current Flutter plugin ecosystem: file_picker,
    // wakelock_plus, device_info_plus, etc.) — GeneratedPluginRegistrant.java
    // fails with "cannot find symbol" because the Kotlin plugin classes
    // aren't on the javac classpath yet. Must stay >= 8.9.1 too — the
    // `camera` package's androidx.camera 1.6.0 transitive deps require it.
    id("com.android.application") version "8.12.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false
}

include(":app")
