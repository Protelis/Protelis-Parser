plugins {
	application
	alias(libs.plugins.shadowJar)
}

dependencies {
	api(project(":protelis.parser"))
	api(libs.bundles.xtext.ide)
}

application {
	mainClass.set("org.eclipse.xtext.ide.server.ServerLauncher")
}
