import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "com.mapboxvelocity"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.mapboxvelocity"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Read token directly from local.properties
        val localProps = Properties().also { props ->
            val f = project.rootProject.file("local.properties")
            if (f.exists()) f.inputStream().use { props.load(it) }
        }
        val mapboxToken = localProps.getProperty("MAPBOX_ACCESS_TOKEN") 
            ?: project.findProperty("MAPBOX_ACCESS_TOKEN") as? String 
            ?: ""

        buildConfigField("String", "MAPBOX_ACCESS_TOKEN", "\"$mapboxToken\"")
        resValue("string", "mapbox_access_token", mapboxToken)
        manifestPlaceholders["MAPBOX_ACCESS_TOKEN"] = mapboxToken
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.google.material)
    implementation(libs.androidx.material.icons)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.mapbox.maps)
    implementation(libs.mapbox.compose)
    implementation(libs.play.services.location)
    implementation(libs.okhttp)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.kotlinx.coroutines.play.services)
    implementation(libs.androidx.datastore.preferences)
    debugImplementation(libs.androidx.ui.tooling)
}
