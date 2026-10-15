import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The upload key lives in android/key.properties, which is git-ignored (so is every
// *.jks / *.keystore): see android/key.properties.example. Without it a release build
// falls back to the debug key, which is fine for `flutter run --release` but is not a
// publishable build.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
val keystoreProperties = Properties()
if (hasReleaseKey) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingProperty(name: String): String =
    keystoreProperties.getProperty(name)
        ?: throw GradleException("android/key.properties is missing '$name'")

android {
    namespace = "com.ronybrand.flutter_state"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ronybrand.estados"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                // Absolute, or relative to android/app.
                storeFile = file(signingProperty("storeFile"))
                storePassword = signingProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// An app bundle is only ever built to upload to Google Play, which rejects one
// signed with the debug key. Fail now, with the reason, instead of producing a file
// that fails later in the Play Console.
gradle.taskGraph.whenReady {
    if (!hasReleaseKey && allTasks.any { it.name == "bundleRelease" }) {
        throw GradleException(
            "Refusing to build a release app bundle without android/key.properties " +
                "(it would be signed with the debug key and rejected by Google Play). " +
                "Create the upload key and the file: see android/key.properties.example."
        )
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
