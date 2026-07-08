plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.example.kytherapro"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.kytherapro"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Force resolve ffmpeg-kit jika git source tidak tersedia
configurations.all {
    resolutionStrategy {
        eachDependency {
            if (requested.group == "com.arthenica" && requested.name == "ffmpeg-kit-min-gpl") {
                useVersion("6.0-2.LTS")
                because("arthenica 6.0-2 dihapus dari Maven, pakai LTS variant")
            }
        }
    }
}

flutter {
    source = "../.."
}
