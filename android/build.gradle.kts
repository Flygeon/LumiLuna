allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Apply AAR metadata check suppression to all subprojects (including
// third-party plugins like file_picker whose pre-compiled AARs may target
// an older compileSdk than what our app requires).
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                checkReleaseAarMetadata = false
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
