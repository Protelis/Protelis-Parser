plugins {
	war
}

dependencies {
	api(project(":protelis.parser"))
	api(project(":protelis.parser.ide"))
	api(libs.bundles.xtext.web)
	providedCompile(libs.jetty.annotations)
	providedCompile(libs.slf4j.simple)
}

val jettyRun by tasks.registering(JavaExec::class) {
	val runtimeClasspath = sourceSets.main.map { it.runtimeClasspath }
	dependsOn(runtimeClasspath)
	classpath = runtimeClasspath.map { collection -> collection.filter { file -> file.exists() } }.get()
	mainClass.set("org.protelis.parser.web.ServerLauncher")
	standardInput = System.`in`
	group = "run"
	description = "Starts an example Jetty server with your language"
}
