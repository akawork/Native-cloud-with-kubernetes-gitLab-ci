#!/bin/bash 
REPONAME=$1
ECRIMAGEURI=$2
IMAGETAG=$3
# Install kubectl
echo 'Installing kubectl'
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
export PATH=/usr/local/bin:$PATH
mkdir -p ~/.kube
cp -rf ./kubeconfig ~/.kube/config
kubectl version
# Deploy
echo 'Deploying'
#if [ -z $DeploymentBranch ]; then
#   sed "s~IMAGEURI~$(printf $ECRIMAGEURI)~g" ./deploy.yaml > newdeploy.yaml
#else
sed "s~IMAGEURI~$(printf $ECRIMAGEURI):$IMAGETAG~g" ./deploy-stag-frontend-example.yaml > newdeploy.yaml
#fi
$(aws ecr get-login --no-include-email --region us-east-2)
kubectl create secret generic regcred --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson --dry-run -o yaml | kubectl apply -f -
kubectl apply -f newdeploy.yaml 
rm -rf newdeploy.yaml
