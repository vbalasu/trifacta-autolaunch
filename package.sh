export AWS_PROFILE=default
chalice package --merge-template trifacta-enterprise-7.6.1-existing-vpc.mod.yaml out
aws cloudformation package \
     --template-file out/sam.yaml \
     --s3-bucket trifacta-autolaunch-us-west-2 \
     --output-template-file trifacta-packaged.yaml
export CODE_URI=$(cat trifacta-packaged.yaml | yq -r .Resources.APIHandler.Properties.CodeUri)
export KEY=$(echo $CODE_URI | sed -e 's/s3:\/\/trifacta-autolaunch-us-west-2\///')
aws s3api put-object-acl --acl public-read --bucket trifacta-autolaunch-us-west-2 --key $KEY