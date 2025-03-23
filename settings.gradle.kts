/*
 * Copyright (C) 2024, Danilo Pianini and contributors listed in the project's build.gradle.kts file.
 *
 * This file is part of Protelis, and is distributed under the terms of the GNU General Public License,
 * with a linking exception, as described in the file LICENSE.txt in this project's top directory.
 */

plugins {
    id("com.gradle.develocity") version "3.19.2"
    id("org.danilopianini.gradle-pre-commit-git-hooks") version "2.0.22"
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.9.0"
}

include("protelis.parser")
include("protelis.parser.ide")
include("protelis.parser.web")

rootProject.name = "protelis.parser.parent"

develocity {
    buildScan {
        termsOfUseUrl = "https://gradle.com/terms-of-service"
        termsOfUseAgree = "yes"
        uploadInBackground = !System.getenv("CI").toBoolean()
    }
}

gitHooks {
    commitMsg { conventionalCommits() }
    preCommit {
        tasks("build", "--parallel")
    }
    createHooks(overwriteExisting = true)
}
