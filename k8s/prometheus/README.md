git clone -b release-0.10 https://github.com/prometheus-operator/kube-prometheus.git


kubectl apply --server-side -f manifests/setup

kubectl apply --server-side -f manifests