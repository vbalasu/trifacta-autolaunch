chalice package --merge-template trifacta-enterprise-7.6.1-existing-vpc.mod.yaml out
aws cloudformation package \
     --template-file out/sam.yaml \
     --s3-bucket trifacta-autolaunch-us-west-2 \
     --output-template-file trifacta-packaged.yaml
