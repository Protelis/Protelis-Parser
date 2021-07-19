10.2.0

* Add initial support to Java 16. Using `--illegal-access=permit` may be needed for the parser to work un Java 16+
* In order to build on Java 8, the file in .mvn/jvm.config must be deleted
* Updated Xtext to 2.26.0.M1
* Updated MWE2 to 2.12.1
* Guice 5.0.1 is forced as explicit dependency, as it is required to work under Java 16 

