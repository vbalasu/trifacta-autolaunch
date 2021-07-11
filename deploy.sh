export AWS_PROFILE=default
aws cloudformation deploy --template-file trifacta-packaged.yaml --stack-name trifacta-stack3 --capabilities CAPABILITY_IAM
