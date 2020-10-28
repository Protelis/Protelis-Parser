#!/usr/bin/env ruby
# This script works around issues with Java > 14 and Tycho 1.7.0, which is required to run with Java 8
java_output = `javac -version 2>&1`
javac_version = java_output.match(/javac (\d*)\..*/)[1]
pom_file = 'pom.xml'
if javac_version.to_i > 14 then
	pom = File.read(pom_file)
	new_pom = pom.gsub('<tycho-version>1.7.0</tycho-version>', '<tycho-version>2.0.0</tycho-version>')
	File.write(pom_file, new_pom)
end
