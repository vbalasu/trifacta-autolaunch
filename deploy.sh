export AWS_PROFILE=default
aws cloudformation deploy --template-file trifacta-packaged.yaml \
     --stack-name trifacta-fullstack3 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
     --parameter-overrides \
       KeyName=vbalasubramaniam-keypair-2 \
       VPCId=vpc-028790bed3b4c1e31 \
       TrifactaSubnet=subnet-066fa3a93afa0da9b \
       EMRSubnet=subnet-04f3c23fedb009ecb
