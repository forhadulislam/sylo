#!/bin/bash


echo "I am being executed";

varRepos=$(cat /app/sample.yaml | shyaml get-value metadata);
echo -e "${varRepos}";

anotherVar=$(echo -e "${varRepos}" | shyaml get-value name);
echo $anotherVar;

