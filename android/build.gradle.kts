buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugin de Gradle para Android
        classpath 'com.android.tools.build:gradle:7.3.0'

        // Plugin de Google Services (Firebase)
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
