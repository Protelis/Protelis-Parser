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
![Code Climate coverage](https://img.shields.io/codeclimate/coverage/Protelis/Protelis-parser)
![Codecov](https://img.shields.io/codecov/c/github/Protelis/Protelis-parser)
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
![GitHub issues](https://img.shields.io/github/issues/Protelis/Protelis-parser)
![GitHub closed issues](https://img.shields.io/github/issues-closed/Protelis/Protelis-parser)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Protelis/Protelis-parser)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/Protelis/Protelis-parser)
![GitHub commit activity](https://img.shields.io/github/commit-activity/y/Protelis/Protelis-parser)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/Protelis/Protelis-parser/latest/develop)
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

### Development process

Create your own fork of this project,
make changes, and open a pull request towards the `develop` branch of this project.
To make sure that changes get accepted,
please open a discussion first on the [Protelis issue tracker](https://github.com/Protelis/Protelis/issues),
where the project maintainer may contribute.

### Importing the project

Eclipse is probably the best IDE to develop this component,
as it relies on the Xtext infrastructure.

* Install Eclipse
* Install the Xtext plugin from the Eclipse Marketplace
* Clone the project
* Import the project in Eclipse.

#### Troubleshooting issues with the target platform

Even though we provide a target definition that you can use You can use your own Eclipse as a target platform for developing the system,
the standard target is enforced in continuous integration anyway.

You can pick the target plaform of your like from within the Eclipse preferences:

![image](https://user-images.githubusercontent.com/1991673/77746024-9803c300-701c-11ea-9e1b-bdfa45908677.png)

### Generating the grammar from within Eclipse

If you make a change to the `Protelis.xtext` file describing the language grammar and crossreferences,
you need to re-generate the parsing and linking infrastructure.

To do so, right click on the GenerateProtelis.mw2 file and run as MWE2 Workflow:

![image](https://user-images.githubusercontent.com/1991673/77746344-152f3800-701d-11ea-81cf-461ea0c96fe2.png)

### Launching a custom Eclipse IDE with the in-development plugin installed

If you want to quickly test your changes within an Eclipse environment,
you can do so by launching the `.ui` project as Eclipse Application:

![image](https://user-images.githubusercontent.com/1991673/77746542-5a536a00-701d-11ea-9b13-746c0530adc1.png)

A new Eclipse IDE will pop up with your changes installed. Now:
2. In the new Eclipse application that launches and make a new Java project
125
3. Right click on the project and select: Configure > Add Xtext Nature
126
4. In the src folder, create a new file, named [something].pt (.pt means it is a Protelis file)
127
5. Write some Protelis code or hit Ctrl-space for autocompletion: you should be getting Protelis syntax evaluation and coloring

### Writing tests

All new features or bug fixes should get appropriately tested.
To do so, there is a testing infrastructure in place.
New tests can be defined in the `protelis.parser.test` project,
inside the `ProtelisParsingTest.xtend` file.

The structure should be clear, and support is provided to verify that pieces of code emit warnings, throw errors, or parse correctly.

### Co-develop Protelis DSL and Protelis VM

In order to co-develop on the Protelis DSL and VM simultaneously, you will need to leverage the local Maven repository.
Once the changes in the parser are satisfactory, proceed as follows:
0. (optional but recommended) customize the project version. To do so, search project-wide in Eclipse for the current version, and replace it in `pom.xml` and `MANIFEST.MF` files with one of your like;
0. pull up a terminal and run `mvn clean install` (you must have Apache Maven installed)
0. open the Protelis interpreter project in a separate IDE;
0. change the `build.gradle.kts` file of the interpreter project by adding, inside the `repositories` block, a call to the `mavenLocal()` method as the first entry of the block;
0. in the `versions.properties` file of the interpreter project, change the parser version to the one you picked for your modified parser;
0. tell your IDE of choice for the interpreter to refresh the Gradle project import;
0. you should now be working with your custom parser!

