export AWS_PROFILE=default
aws cloudformation deploy --template-file trifacta-packaged.yaml --stack-name trifacta-stack7 --capabilities CAPABILITY_IAM
