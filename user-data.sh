# BEGIN Cloudformation template UserData section
#            #!/bin/bash -xe
#            exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#            yum install -y git jq
#            cd /root
#            git clone https://github.com/vbalasu/trifacta-autolaunch.git
#            trifacta-autolaunch/user-data.sh
# END Cloudformation template UserData section
cd /root
export TRIFACTA_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
export STACK_NAME=$(aws ec2 describe-instances --instance-ids $TRIFACTA_INSTANCE_ID --region $AWS_REGION |jq '.Reservations[].Instances[].Tags[] |select(.Key == "aws:cloudformation:stack-name").Value' -r)
aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION>stack.json

export TRIFACTA_URL=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaUrl").OutputValue' -r)
export TRIFACTA_BUCKET=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "TrifactaBucket").OutputValue' -r)
export EMR_CLUSTER_ID=$(cat stack.json |jq '.Stacks[].Outputs[] | select(.OutputKey == "EmrClusterId").OutputValue' -r)

# Set aws.s3.enabled to true using configuration service
curl -s -X PUT -H 'Content-Type: application/json' --data 'true' localhost:10075/v1/setting/aws.s3.enabled/system/1

# Update triconf
python3 trifacta-autolaunch/update_triconf.py
service trifacta restart

# Obtain token
curl -s -X POST -H "Content-Type: application/json" -d '{"lifetimeSeconds":86400, "description":"Autolaunch 1 day token"}' -u admin@trifacta.local:$TRIFACTA_INSTANCE_ID $TRIFACTA_URL/v4/apiAccessTokens >token.json
export TRIFACTA_TOKEN=$(cat token.json | jq '.tokenValue' -r)

# Configure EMR
curl -s -X POST -H "Content-Type: application/json" -d "{\"emrClusterId\": \"$EMR_CLUSTER_ID\", \"resourceBucket\": \"$TRIFACTA_BUCKET\", \"resourcePath\": \"resources\"}" -H "Authorization: Bearer $TRIFACTA_TOKEN" $TRIFACTA_URL/v4/emrClusters

echo "All done!"
