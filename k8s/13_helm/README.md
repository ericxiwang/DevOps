## run helm chart to deploy flask/jenkins/mysql/selenium-hub
 `$ helm install {{ deploy-name }} CI_CD_helm

## check helm template status
 `$ helm template -s {{ mysql-service }}  CI_CD_helm/charts/mysql-service/