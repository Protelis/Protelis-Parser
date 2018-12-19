#!/bin/bash
echo "Making sure every file is Java 7 compatible"
for it in `find . -name "*.class" -exec javap -verbose {} \; | grep --text "major"`
#for it in *
do
  echo -n .
  VERSION="`echo "$it" | sed 's/[^0-9]*//g'`"
  if (( VERSION > 51 ))
  then
    echo "One file has been found with bytecode version ${VERSION}"
    exit 1
  fi
done
exit 0

