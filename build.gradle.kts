import org.gradle.api.tasks.testing.logging.TestLogEvent

buildscript {
	repositories {
		mavenCentral()
		gradlePluginPortal()
	}
	dependencies {
		classpath("org.xtext:xtext-gradle-plugin:4.0.0")
	}
}

plugins{
	`java-library`
	alias(libs.plugins.gitSemVer)
	alias(libs.plugins.kotlin.qa)
	alias(libs.plugins.multiJvmTesting)
	alias(libs.plugins.publishOnCentral)
	alias(libs.plugins.shadowJar)
}

val Provider<PluginDependency>.id get() = get().pluginId

allprojects {
	group = "org.protelis"
	with(rootProject.libs.plugins) {
		apply(plugin = gitSemVer.id)
		apply(plugin = multiJvmTesting.id)
		apply(plugin = publishOnCentral.id)
	}

	if (System.getenv("CI") == true.toString()) {
		signing {
			val signingKey: String? by project
			val signingPassword: String? by project
			useInMemoryPgpKeys(signingKey, signingPassword)
		}
	}

	publishOnCentral {
		projectDescription.set("Parser for Protelis, the practical aggregate programming language")
		projectLongName.set("Protelis Parser")
		licenseName.set("GPLv3 with linking exception")
		licenseUrl.set("https://github.com/Protelis/Protelis-Parser/blob/master/LICENSE.txt")
		projectUrl.set("http://www.protelis.org")
		scmConnection.set("git:git@github.com:Protelis/Protelis-Parser.git")
	}

	publishing.publications {
		withType<MavenPublication> {
			pom {
				developers {
					developer {
						name.set("Danilo Pianini")
						email.set("danilo.pianini@unibo.it")
						url.set("https://danysk.github.io")
					}
				}
				contributors {
					contributor {
						name.set("Mirko Viroli")
						email.set("mirko.viroli@unibo.it")
						url.set("http://mirkoviroli.apice.unibo.it/")
					}
					contributor {
						name.set("Jacob Beal")
						email.set("jakebeal@gmail.com")
						url.set("http://web.mit.edu/jakebeal/www/")
					}
				}
			}
		}
	}

}

subprojects {
	repositories {
		mavenCentral()
	}

	extra["xtextVersion"] = rootProject.libs.versions.xtext.get()
	apply(plugin = "java-library")
	dependencies {
		api(platform(rootProject.libs.xtext.dev.bom))
	}
	apply(plugin = "org.xtext.xtend")
	apply(from = "${rootDir}/gradle/source-layout.gradle")

	val minJavaVersion = 17
	multiJvm {
		jvmVersionForCompilation.set(minJavaVersion)
		maximumSupportedJvmVersion.set(latestJava)
	}

	configurations.configureEach {
		exclude(group = "asm")
	}

	tasks.withType<Test>().configureEach {
        failFast = true
		useJUnitPlatform()
		testLogging {
			events(*TestLogEvent.values())
			showStandardStreams = true
		}
	}

	tasks.withType<Javadoc>().configureEach {
		isFailOnError = false
		options {
			javadocTool.set(
				javaToolchains.javadocToolFor {
					languageVersion.set(JavaLanguageVersion.of(minJavaVersion))
				},
			)
			encoding = "UTF-8"
			val title = "Protelis ${project.version} Javadoc API"
			windowTitle(title)
		}
	}

	tasks.sourcesJar {
		duplicatesStrategy = DuplicatesStrategy.WARN
	}
}
