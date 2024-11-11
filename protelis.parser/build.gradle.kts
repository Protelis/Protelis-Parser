dependencies {
	api(libs.xtext)
	api(libs.xbase)
	testImplementation(libs.bundles.xtext.testing)
	testImplementation("org.junit.jupiter:junit-jupiter-api")
	testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

val mwe2 by configurations.creating {
	extendsFrom(configurations.compileClasspath.get())
}

dependencies {
	mwe2("org.eclipse.emf:org.eclipse.emf.mwe2.launch")
	mwe2("org.eclipse.xtext:xtext-antlr-generator")
	mwe2(libs.bundles.xtext.mwe2)
}

val generateXtextLanguage by tasks.registering(JavaExec::class) {
	mainClass.set("org.eclipse.emf.mwe2.launch.runtime.Mwe2Launcher")
	classpath = configurations["mwe2"]
	inputs.file("src/main/java/org/protelis/parser/GenerateProtelis.mwe2")
	inputs.file("src/main/java/org/protelis/parser/Protelis.xtext")
	outputs.dir("src/main/xtext-gen")
	args("src/main/java/org/protelis/parser/GenerateProtelis.mwe2", "-p", "rootPath=/${projectDir}/..")
}

tasks {
	processResources.configure {
		dependsOn(generateXtextLanguage)
	}
	generateXtext.configure {
		dependsOn(generateXtextLanguage)
	}
	clean.configure {
		dependsOn("cleanGenerateXtextLanguage")
	}
}
