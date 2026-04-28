pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication { create<BasicAuthentication>("basic") }
            credentials {
                username = "mapbox"
                password = providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN")
                    .orElse(
                        providers.fileContents(
                            layout.settingsDirectory.file("local.properties")
                        ).asText.map { content ->
                            content.lines()
                                .firstOrNull { it.startsWith("MAPBOX_DOWNLOADS_TOKEN=") }
                                ?.removePrefix("MAPBOX_DOWNLOADS_TOKEN=")
                                ?.trim() ?: ""
                        }
                    ).get()
            }
        }
    }
}

rootProject.name = "MapboxVelocity"
include(":app")
