chalice package --merge-template app-stack.yaml out
aws cloudformation package \
     --template-file out/sam.yaml \
     --s3-bucket trifacta-autolaunch-us-west-2 \
     --output-template-file trifacta-packaged.yaml
