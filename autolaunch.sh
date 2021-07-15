# Trifacta autolaunch script
export PATH_TO_KEY="/Users/vbalasubramaniam/Desktop/amazon/vbalasubramaniam-keypair-2.pem"
export STACK_NAME="trifacta-fullstack6"

aws cloudformation describe-stacks --stack-name $STACK_NAME >stack.json
aws cloudformation describe-stack-resources --stack-name $STACK_NAME >stack-resources.json
export TRIFACTA_URL=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaUrl").OutputValue' -r)
export TRIFACTA_INSTANCE_ID=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaInstanceId").OutputValue' -r)
export TRIFACTA_BUCKET=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaBucket").OutputValue' -r)
export EMR_CLUSTER_ID=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "EmrClusterId").OutputValue' -r)
export TRIFACTA_PUBLIC_DNS_NAME=$(aws ec2 describe-instances --instance-ids $TRIFACTA_INSTANCE_ID |jq '.Reservations[].Instances[].PublicDnsName' -r)
curl -s -X POST -H "Content-Type: application/json" -d '{"lifetimeSeconds":86400, "description":"Autolaunch 1 day token"}' -u admin@trifacta.local:$TRIFACTA_INSTANCE_ID $TRIFACTA_URL/v4/apiAccessTokens >token.json
export TRIFACTA_TOKEN=$(cat token.json | jq '.tokenValue' -r)

# Set aws.s3.enabled to true using configuration service
ssh -i $PATH_TO_KEY centos@$TRIFACTA_PUBLIC_DNS_NAME "curl -s -X PUT -H 'Content-Type: application/json' --data 'true' localhost:10075/v1/setting/aws.s3.enabled/system/1"

# Copy update_triconf.py to server and execute it
scp -i $PATH_TO_KEY update_triconf.py centos@$TRIFACTA_PUBLIC_DNS_NAME:update_triconf.py
scp -i $PATH_TO_KEY stack.json centos@$TRIFACTA_PUBLIC_DNS_NAME:stack.json
ssh -i $PATH_TO_KEY centos@$TRIFACTA_PUBLIC_DNS_NAME "sudo python3 update_triconf.py"
ssh -i $PATH_TO_KEY centos@$TRIFACTA_PUBLIC_DNS_NAME "sudo service trifacta restart"

# Configure EMR
curl -s -X POST -H "Content-Type: application/json" -d "{\"emrClusterId\": \"$EMR_CLUSTER_ID\", \"resourceBucket\": \"$TRIFACTA_BUCKET\", \"resourcePath\": \"resources\"}" -H "Authorization: Bearer $TRIFACTA_TOKEN" $TRIFACTA_URL/v4/emrClusters

echo "All done!"
