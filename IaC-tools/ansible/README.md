## Install Kubernetes dependencies on all servers
 `$ ansible-playbook  k8s-init/tasks/k8s-inst.yml -kK`
 
## Initialize the master node
 `$ ansible-playbook k8s-init/tasks/master.yml -kK`
 
`ssh` onto the master and verify that the master node get status `Ready`:

## Add the worker nodes
 `$ ansible-playbook k8s-init/tasks/worker.yml -kK`

Run `kubectl get nodes` once more on the master node to verify the worker nodes got added.