#!/bin/bash
[ -z "$1" -o -z "$2" ] && echo "Usage: execution.sh [RANDOM NUMBER] [RESTART OPTION - 0/1]" && exit 1

set -xe

RESTART=$2
LAMBDA_HOST="http://localhost:4566"
STEP_FUNCTIONS_HOST="http://localhost:8083"
STATE_MACHINE_NAME="LambdaStateMachine"

function zip_files {
  path=$(pwd)
  cd state_machines/lambda
  files=$(ls | grep -e ".js$")

  for file in $files; do
    echo "Ziping file $file"
    zip - $file > "${file%.*}".zip
  done

  cd $path
}

function create_lambda_functions {
  files=$(ls state_machines/lambda | grep -e ".zip$")

  for file in $files; do
    file_name="${file%.*}"
    capitalize_file_name="${file_name^}"
    function_name="${capitalize_file_name}Function"
  
    aws --endpoint "$LAMBDA_HOST" \
      lambda delete-function \
      --function-name $function_name

    aws --endpoint "$LAMBDA_HOST" \
      lambda create-function \
      --function-name $function_name \
      --runtime nodejs12.x \
      --handler "${file_name}.handler" \
      --role arn:aws:iam::012345678901:role/DummyRole \
      --zip-file "fileb://state_machines/lambda/${file_name}.zip"
  done
}

if [ "$RESTART" != "1" ]; then
  zip_files
  create_lambda_functions

  aws stepfunctions \
    --endpoint "$STEP_FUNCTIONS_HOST" \
    delete-state-machine \
    --state-machine-arn "arn:aws:states:us-east-1:123456789012:stateMachine:$STATE_MACHINE_NAME"

  sleep 1

  aws stepfunctions \
    --endpoint "$STEP_FUNCTIONS_HOST" \
    create-state-machine \
    --definition file://state_machines/lambda/state_machine.json \
    --name "$STATE_MACHINE_NAME" \
    --role-arn "arn:aws:iam::012345678901:role/DummyRole"

  sleep 2
fi

RANDOM_NAME=$(date +%s)

aws stepfunctions \
  --endpoint "$STEP_FUNCTIONS_HOST" \
  start-execution \
  --state-machine arn:aws:states:us-east-1:123456789012:stateMachine:$STATE_MACHINE_NAME \
  --name $RANDOM_NAME \
  --input "{\"numberParam\":$1}"

sleep 2

aws stepfunctions \
  --endpoint "$STEP_FUNCTIONS_HOST" \
  describe-execution \
  --execution-arn "arn:aws:states:us-east-1:123456789012:execution:$STATE_MACHINE_NAME:$RANDOM_NAME"
