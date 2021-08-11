aws stepfunctions \
  --endpoint http://localhost:8083 \
  create-state-machine \
  --definition file://state_machines/simple/state_machine.json \
  --name "SimpleStateMachine" \
  --role-arn "arn:aws:iam::012345678901:role/DummyRole"

aws stepfunctions \
  --endpoint http://localhost:8083 \
  start-execution \
  --state-machine arn:aws:states:us-east-1:123456789012:stateMachine:SimpleStateMachine \
  --name test3 \
  --input '{"IsHelloWorldExample":true}'

aws stepfunctions \
  --endpoint http://localhost:8083 \
  describe-execution \
  --execution-arn arn:aws:states:us-east-1:123456789012:execution:SimpleStateMachine:test3
