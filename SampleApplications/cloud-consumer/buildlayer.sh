rm -rf package
mkdir -p package/python/lib
cd package
cp ../requirements.txt ./
docker run -v "$PWD":/var/task "public.ecr.aws/sam/build-python3.11" /bin/sh -c "pip install -r requirements.txt -t python/lib/python3.11/site-packages/; exit"
zip -r python_layers.zip python
aws lambda publish-layer-version --layer-name python3Layer --description "python layer with kafka and aws-sdk, flask" --license-info "MIT" --compatible-runtimes python3.11 --zip-file fileb://./python_layers.zip --region us-east-2
