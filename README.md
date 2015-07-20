# Protelis-Parser
Parser for Protelis, the practical aggregate programming language

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
