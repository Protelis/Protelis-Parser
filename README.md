# Protelis-Parser
Parser for Protelis, the practical aggregate programming language

## Badges

### Info
![Travis (.com)](https://img.shields.io/travis/com/Protelis/Protelis-parser)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/3810/badge)](https://bestpractices.coreinfrastructure.org/projects/3810)
![GitHub language count](https://img.shields.io/github/languages/count/Protelis/Protelis-parser)
![GitHub top language](https://img.shields.io/github/languages/top/Protelis/Protelis-parser)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=ncloc)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Protelis/Protelis-parser)
![GitHub repo size](https://img.shields.io/github/repo-size/Protelis/Protelis-parser)
![Maven Central](https://img.shields.io/maven-central/v/org.protelis/protelis.parser)
![GitHub contributors](https://img.shields.io/github/contributors/Protelis/Protelis-parser)

### Coverage
![Codacy coverage](https://img.shields.io/codacy/coverage/b27fc7ed29a944e1a17b148e58435d86)
![Code Climate coverage](https://img.shields.io/codeclimate/coverage/Protelis/Protelis-Parser)
![Codecov](https://img.shields.io/codecov/c/github/Protelis/Protelis-Parser)
*[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=coverage)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)*

### Quality
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b27fc7ed29a944e1a17b148e58435d86)](https://www.codacy.com/manual/danilo-pianini/Protelis-Parser?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Protelis/Protelis-Parser&amp;utm_campaign=Badge_Grade)
![Code Climate coverage](https://img.shields.io/codeclimate/coverage/Protelis/Protelis-parser)
![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability-percentage/Protelis/Protelis-parser)
![Code Climate maintainability](https://img.shields.io/codeclimate/issues/Protelis/Protelis-parser)
![Code Climate maintainability](https://img.shields.io/codeclimate/tech-debt/Protelis/Protelis-parser)
[![CodeFactor](https://www.codefactor.io/repository/github/Protelis/Protelis-parser/badge)](https://www.codefactor.io/repository/github/Protelis/Protelis-parser)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=alert_status)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=bugs)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=code_smells)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=duplicated_lines_density)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=security_rating)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=sqale_index)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=Protelis_Protelis-Parser&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=Protelis_Protelis-Parser)

### Progress
![GitHub issues](https://img.shields.io/github/issues/Protelis/Protelis-Parser)
![GitHub closed issues](https://img.shields.io/github/issues-closed/Protelis/Protelis-Parser)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Protelis/Protelis-Parser)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/Protelis/Protelis-Parser)
![GitHub commit activity](https://img.shields.io/github/commit-activity/y/Protelis/Protelis-parser)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/Protelis/Protelis-Parser/latest/master)
![GitHub last commit](https://img.shields.io/github/last-commit/Protelis/Protelis-parser)

## What is it

This project hosts the parsing infrastructure of the Protelis programming language, as well as its Eclipse plugin.
It is a plain Xtext project.
Users interested in using Protelis should most likely refer to [the official Protelis website](www.protelis.org).
This project is of use for Protelis developers willing to make changes to the language itself.

## Contributing

### Bug reports

Issues for this project are tracked together with the [issues of the Protelis interpreter](https://github.com/Protelis/Protelis/issues).
Please open bug reports and feature requests there.

### Importing the project

Eclipse is probably the best IDE to develop this component,
as it relies on the Xtext infrastructure.

* Install Eclipse
* Install the Xtext plugin from the Eclipse Marketplace
* Clone the project
* Import the project in Eclipse.

### Writing tests

All new features or bug fixes should get appropriately tested.
To do so, there is a testing infrastructure in place.
New tests can be defined in the `protelis.parser.test` project,
inside the `ProtelisParsingTest.xtend` file.

The structure should be clear, and support is provided to verify that pieces of code emit warnings, throw errors, or parse correctly.

### Build with Gradle

The project is built with Gradle:
* On Unix, run `./gradlew build --parallel`
* On Windows, run `gradlew.bat build --parallel`

### Co-develop Protelis DSL and Protelis VM

In order to co-develop on the Protelis DSL and VM simultaneously, you will need to leverage the local Maven repository.
Once the changes in the parser are satisfactory, proceed as follows:
1. In the main `build.gradle.kts` file, enable publishing on the local Maven repository by adding `mavenLocal()`
    to the `repositories` block found inside `subprojects`;
0. pull up a terminal and run `./gradlew publishJavaOnMavenLocal`;
0. open the Protelis interpreter project in a separate IDE;
0. change the `build.gradle.kts` file of the interpreter project by adding,
    inside the `repositories` block, a call to the `mavenLocal()` method *as the first entry of the block*;
0. in the `gradle/libs.versions.toml` file of the interpreter project,
    change the parser version to the one you picked for your modified parser;
0. tell your IDE of choice for the interpreter to refresh the Gradle project import;
0. you should now be working with your custom parser!
