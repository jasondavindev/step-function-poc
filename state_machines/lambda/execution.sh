zip state_machines/lambda/square.zip state_machines/lambda/square.js

aws --endpoint http://localhost:4566 \
  lambda delete-function \
  --function-name SquareFunction

aws --endpoint http://localhost:4566 \
  lambda create-function \
  --function-name SquareFunction \
  --runtime nodejs12.x \
  --handler square.handler \
  --role arn:aws:iam::012345678901:role/DummyRole \
  --zip-file fileb://state_machines/lambda/square.zip

RANDOM_NAME=$(date +%s)

aws stepfunctions \
  --endpoint http://localhost:8083 \
  delete-state-machine \
  --state-machine-arn "arn:aws:states:us-east-1:123456789012:stateMachine:LambdaStateMachine"

aws stepfunctions \
  --endpoint http://localhost:8083 \
  create-state-machine \
  --definition file://state_machines/lambda/state_machine.json \
  --name "LambdaStateMachine" \
  --role-arn "arn:aws:iam::012345678901:role/DummyRole"

aws stepfunctions \
  --endpoint http://localhost:8083 \
  start-execution \
  --state-machine arn:aws:states:us-east-1:123456789012:stateMachine:LambdaStateMachine \
  --name $RANDOM_NAME \
  --input '{"numberParam":25}'

aws stepfunctions \
  --endpoint http://localhost:8083 \
  describe-execution \
  --execution-arn "arn:aws:states:us-east-1:123456789012:execution:LambdaStateMachine:$RANDOM_NAME"
