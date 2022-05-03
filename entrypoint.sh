#!/bin/bash -l

set -e

#CMD> && <SUCCESS_ACTION> || <FAIL_ACTION>
#echo sonar.host.url=\"${ENVCMD//[$'\t\r\n']}\""

echo "Debug"

echo $SONAR_PROJECT_KEY
echo $SONAR_HOST
echo $SONAR_TOKEN
echo $SONAR_EXTRA_ARG

echo "end Debug"

begin_cmd="sonar-scanner \\
    -Dsonar.projectKey=\"${SONAR_PROJECT_KEY//[$'\t\r\n']:?Please set the projectKey environment variable.}\" \\
    -Dsonar.host.url=\"${SONAR_HOST:?Please set the SONAR_HOST environment variable.}\" \\
    -Dsonar.login=\"${SONAR_TOKEN:?Please set the SONAR_TOKEN environment variable.}\" \\
    -Dsonar.sourceEncoding=UTF-8"

echo "Begin command"
echo $begin_cmd

#if string exists and is not empty.
if [ ! -z "$SONAR_EXTRA_ARG" ]
then
    begin_cmd="$begin_cmd $SONAR_EXTRA_ARG"
    echo "Complete begin command"
    echo $begin_cmd
fi

sh -c "$begin_cmd"

echo "Checking if the result exist."
if [ -f ".scannerwork/report-task.txt" ]
then
  /runner/check-quality-gate.sh .scannerwork/report-task.txt
fi
