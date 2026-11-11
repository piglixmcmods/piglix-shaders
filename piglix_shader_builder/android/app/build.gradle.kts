import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
var hasReleaseSigning = false

val envStorePath = System.getenv("ANDROID_KEYSTORE_PATH")
if (!envStorePath.isNullOrEmpty() && file(envStorePath).exists()) {
    hasReleaseSigning = true
} else if (keystorePropertiesFile.exists()) {
    try {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        val storePath = keystoreProperties["storeFile"] as String?
        if (storePath != null && file(storePath).exists()) {
            hasReleaseSigning = true
        }
    } catch (_: Exception) {}
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.piglixlabs.shadermakerformcpe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: (keystoreProperties["keyAlias"] as String?)
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: (keystoreProperties["keyPassword"] as String?)
                val storePath = System.getenv("ANDROID_KEYSTORE_PATH") ?: (keystoreProperties["storeFile"] as String?)
                storeFile = storePath?.let { file(it) }
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: (keystoreProperties["storePassword"] as String?)
            }
        }
    }

    defaultConfig {
        applicationId = "com.piglixlabs.shadermakerformcpe"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
