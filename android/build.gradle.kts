allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Workaround for package_info_plus NullPointerException with AGP 8.7+
gradle.projectsEvaluated {
    rootProject.allprojects {
        afterEvaluate {
            tasks.configureEach {
                if (name.contains("package_info_plus", ignoreCase = true)) {
                    try {
                        enabled = true
                    } catch (e: Exception) {
                        // Ignore evaluation errors for plugin tasks
                    }
                }
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
