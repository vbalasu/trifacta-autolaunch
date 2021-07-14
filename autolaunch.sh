# Trifacta autolaunch script
aws cloudformation describe-stacks --stack-name trifacta-fullstack5 >stack.json
aws cloudformation describe-stack-resources --stack-name trifacta-fullstack5 >stack-resources.json
export TRIFACTA_URL=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaUrl").OutputValue' -r)
export TRIFACTA_INSTANCE_ID=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaInstanceId").OutputValue' -r)
export TRIFACTA_BUCKET=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaBucket").OutputValue' -r)
export EMR_CLUSTER_ID=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "EmrClusterId").OutputValue' -r)
export TRIFACTA_PUBLIC_DNS_NAME=$(aws ec2 describe-instances --instance-ids $TRIFACTA_INSTANCE_ID |jq '.Reservations[].Instances[].PublicDnsName' -r)
export PATH_TO_KEY="/Users/vbalasubramaniam/Desktop/amazon/vbalasubramaniam-keypair-2.pem"
ssh -i $PATH_TO_KEY centos@$TRIFACTA_PUBLIC_DNS_NAME "hostname"
