#!/bin/bash


echo "I am being executed";

varRepos=$(cat /app/sample.yaml | shyaml get-value metadata);
echo -e "${varRepos}";

anotherVar=$(echo -e "${varRepos}" | shyaml get-value name);
echo $anotherVar;

echo $ENTRYPOINT;

shellcheck -e SC2002 -e SC2181 -e SC2044 -e SC2116 -e SC2060 -e SC2016 ./sample.sh;

