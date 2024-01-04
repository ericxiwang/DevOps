echo "===== switch current node to maintain status"

kubectl get nodes
kubectl cordon <node name>
kubectl drain <node name> --delete-emptydir-data --ignore-daemonsets --force


echo "====== ssh to node and upgrade process"


apt update
apt-cache policy kubeadm | grep <version>

apt-get install kubeadm=xx.xx.xx


echo "==== reload kubeadm ======"
kubeadm upgrade plan

systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon <node name>

kubectl get nodes