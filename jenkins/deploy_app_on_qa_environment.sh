echo 'Deploying App on Kubernetes'

envsubst < k8s/petclinic_chart/values-template.yaml > k8s/petclinic_chart/values.yaml
sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/petclinic_chart/Chart.yaml

AWS_REGION=$AWS_REGION helm repo add stable-petclinic s3://petclinic-helm-charts-19-tr/stable/myapp/ || echo "repository name already exists"
AWS_REGION=$AWS_REGION helm repo update

helm package k8s/petclinic_chart
AWS_REGION=$AWS_REGION helm s3 push --force petclinic_chart-${BUILD_NUMBER}.tgz stable-petclinic

kubectl create ns petclinic-qa || echo "namespace petclinic-qa already exists"

kubectl delete secret regcred -n petclinic-qa || echo "there is no regcred secret in petclinic-qa namespace"

kubectl create secret generic regcred -n petclinic-qa \
    --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

AWS_REGION=$AWS_REGION helm repo update

AWS_REGION=$AWS_REGION helm upgrade --install \
    petclinic-app-release stable-petclinic/petclinic_chart --version ${BUILD_NUMBER} \
    --namespace petclinic-qa