import java.util.Properties // This import is crucial for the Properties class

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // This is where signingConfigs should be defined, directly within the android block.
    signingConfigs {
        create("release") {
            // Load keystore properties directly within this configuration block
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystorePropertiesFile.inputStream().use {
                    keystoreProperties.load(it)
                }
            }

            // Assign properties to the signing config
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                println("WARNING: Release keystore properties not found. Ensure key.properties is configured correctly at the project root.")
            }
        }
    }

    namespace = "com.cloudregex.meatzo" // Or "com.example.meatzo" - ensure this matches your MainActivity package
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Set the NDK version as required by plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.cloudregex.meatzo" 
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 7
        versionName = "1.0.7" 
        multiDexEnabled = true
    }

    buildTypes {
        release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true // This must be true for R8 to run
        isShrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:unchecked", "-Xlint:deprecation"))
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0")
    implementation("androidx.multidex:multidex:2.0.1")
    // implementation("androidx.play:core-ktx:1.10.4")// Fix for deferred components
    implementation("com.google.android.gms:play-services-wallet:19.2.1") // Needed for GPay/UPI via Razorpay
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:app-update-ktx:2.1.0")
}
