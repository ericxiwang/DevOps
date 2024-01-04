kubectl get nodes
kubectl cordon ek8s-node-1

kubect drain  --ignore-daemonsets --delete-emptydir-data --force <node-name>


kubectl uncordon <node-name>