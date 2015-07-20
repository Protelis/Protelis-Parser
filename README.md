# Protelis-Parser
Parser for Protelis, the practical aggregate programming language

## Required Eclipse plugins

* Xtext 2.7.3+
* Maven support via m2e
* git

## Project structure

* *alchemist.protelis.parent*:
  the build point, which should pull in all of the others
* *alchemist.protelis*:
  specifies the Protelis DSL and associated utilities using XText
* *alchemist.protelis.target*:
  specifies the Eclipse runtime environment that the DSL plugin should
  be compatible with.
* *alchemist.protelis.ui*:
  Contains the Eclipse plugin to support Protelis editing
* *alchemist.protelis.repository*:
  Packages for the automated install website for Eclipse
* *alchemist.protelis.tests*:
  Makes sure that you can fire up an instance of Eclipse that can
  load the plugin

## Develop and test the plugin using Eclipse

Once the repositories are imported, there will likely be a lot of errors.

* First, if there are "Plugin execution not covered by lifecycle configuration" errors, go to Eclipse Preferences > Maven > Errors/Warnings and switch this error type to warning.  This is OK because Eclipse uses its own build system, and can ignore these Maven problems (which are not due to the Maven configuration, but lack of certain current Eclipse/Maven integrations).
* Second, go to alchemist.protelis project and run src/it.unibo.alchemist.language.protelis/GenerateProtelis.mwe2 as an MWE2 workflow (ignoring the fact that there are errors).  This generates the DSL using Xtext, and should resolve all of the outstanding errors.

When successfully built, this should produce two artifacts:

1. The DSL parser, which is needed for running the Protelis VM
2. The Eclipse plugin, based on the parser, for making it easy to program in Protelis (plus packaging for distributing as an Eclipse plugin)

In order to test both of these at once (there is no separate test for just the DSL):

1. Go to the UI project and run as Eclipse application
2. In the new Eclipse application that launches and make a new Java project
3. Right click on the project and select: Configure > Add Xtext Nature
4. In the src folder, create a new file, named [something].pt (.pt means it is a Protelis file)
5. Write some Protelis code or hit Ctrl-space for autocompletion: you should be getting Protelis syntax evaluation and coloring

## Compile and produce a working artifact for your own use

## Prepare for a release

## How to prepare a working Eclipse environment

A working Eclipse environment is the best way to develop the parser, since it gives immediate feedback about errors.

### Obtaining Eclipse

### Installing required plugins

There are six sub-projects in this repository, all of which should be
imported into Eclipse.

Then what?
How do we know if it worked?

## Dealing with build problems
Maven: plugin lifecycle should be warning, no error
  Change this in Eclipse Preferences > Maven >

Maven needs to be at least version 3.3.3
