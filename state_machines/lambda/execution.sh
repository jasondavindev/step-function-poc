set -x

RESTART=$2
LAMBDA_HOST="http://localhost:4566"
STEP_FUNCTIONS_HOST="http://localhost:8083"

if [ "$RESTART" != "1" ]; then
  path=$(pwd)
  cd state_machines/lambda
  zip - square.js > square.zip
  zip - test.js > test.zip
  cd $path

  aws --endpoint "$LAMBDA_HOST" \
    lambda delete-function \
    --function-name SquareFunction

  aws --endpoint "$LAMBDA_HOST" \
    lambda create-function \
    --function-name SquareFunction \
    --runtime nodejs12.x \
    --handler square.handler \
    --role arn:aws:iam::012345678901:role/DummyRole \
    --zip-file fileb://state_machines/lambda/square.zip

  aws --endpoint "$LAMBDA_HOST" \
    lambda delete-function \
    --function-name TestFunction

  aws --endpoint "$LAMBDA_HOST" \
    lambda create-function \
    --function-name TestFunction \
    --runtime nodejs12.x \
    --handler test.handle \
    --role arn:aws:iam::012345678901:role/DummyRole \
    --zip-file fileb://state_machines/lambda/test.zip


  aws stepfunctions \
    --endpoint "$STEP_FUNCTIONS_HOST" \
    delete-state-machine \
    --state-machine-arn "arn:aws:states:us-east-1:123456789012:stateMachine:LambdaStateMachine"

  aws stepfunctions \
    --endpoint "$STEP_FUNCTIONS_HOST" \
    create-state-machine \
    --definition file://state_machines/lambda/state_machine.json \
    --name "LambdaStateMachine" \
    --role-arn "arn:aws:iam::012345678901:role/DummyRole"

  sleep 1
fi

RANDOM_NAME=$(date +%s)

aws stepfunctions \
  --endpoint "$STEP_FUNCTIONS_HOST" \
  start-execution \
  --state-machine arn:aws:states:us-east-1:123456789012:stateMachine:LambdaStateMachine \
  --name $RANDOM_NAME \
  --input "{\"numberParam\":$1}"

sleep 1

aws stepfunctions \
  --endpoint "$STEP_FUNCTIONS_HOST" \
  describe-execution \
  --execution-arn "arn:aws:states:us-east-1:123456789012:execution:LambdaStateMachine:$RANDOM_NAME"
