#!/bin/bash
#
# A bash script to run CircleCI node/test in parallel
#

NODE_INDEX=${CIRCLE_NODE_INDEX:-0}

set -e

if [ "$NODE_INDEX" = "1" ]; then
  echo "Running node $NODE_INDEX to test 'samples.circleci' defined in pom.xml ..."
  #cp CI/pom.xml.circleci pom.xml
  java -version
  mvn --quiet verify -Psamples.circleci
elif [ "$NODE_INDEX" = "2" ]; then
  # run ensure-up-to-date sample script on SNAPSHOT version only
  project_version=`mvn org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=project.version -q -DforceStdout`
  if [[ $project_version == *"-SNAPSHOT" ]]; then
    echo "Running node $NODE_INDEX to test ensure-up-to-date"
    java -version
    ./bin/utils/ensure-up-to-date
  fi
elif [ "$NODE_INDEX" = "3" ]; then
  echo "Running node $NODE_INDEX to test haskell"
  # install haskell
  url -sSL https://get.haskellstack.org/ | sh
  stack upgrade
  stack --version:w
  mvn --quiet verify -Psamples.misc
else
  echo "Running node $NODE_INDEX to test 'samples.circleci.jdk7' defined in pom.xml ..."
  sudo update-java-alternatives -s java-1.7.0-openjdk-amd64
  java -version
  #cp CI/pom.xml.circleci.java7 pom.xml
  mvn --quiet verify -Psamples.circleci.jdk7
fi


