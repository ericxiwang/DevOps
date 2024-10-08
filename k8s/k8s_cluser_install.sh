

echo "==== disable ufw ===="
systemctl disable ufw
systemctl stop ufw

echo "==== disable setlinux ==== optional "
setenforce 0
sudo vim /etc/selinux/config
SELINUX=disabled

echo "==== disable swap partition ==== optional "
sudo vim /etc/fstab



echo "==== config hosts for each nodes ===="
vim /etc/hosts
192.168.3.89 k8s-master
192.168.3.90 k8s-node1
192.168.3.91 k8s-node2



reboot


echo " ==== install docker ===="

sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io



echo " ==== config net bridge ====  optional"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# manually load
sudo modprobe overlay
sudo modprobe br_netfilter

# config sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# apply sysctl without restart
sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay




echo "==== enable ipvs ==== optional"

#install ipset and ipvsadm：
apt install -y ipset ipvsadm

### enable ipvs forwarding
sudo modprobe br_netfilter 

# load config
cat > /etc/modules-load.d/ipvs.conf << EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF

# temp load
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack

# load config when booting, put ipvs into config file
cat >> /etc/modules <<EOF
ip_vs_sh
ip_vs_wrr
ip_vs_rr
ip_vs
nf_conntrack
EOF

echo "==== config containerd ====="

# copy config to  > config.toml
sudo sh -c "containerd config default > /etc/containerd/config.toml"



#SystemdCgroup = false 改为 SystemdCgroup = true
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml


# reload containerd
systemctl daemon-reload && systemctl restart containerd


echo "==== instal k8s kubelet, kubeadm, and kubectl component ===="

sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir /etc/apt/keyrings



curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

#sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00

sudo apt install -y kubelet kubeadm kubectl


systemctl restart containerd
systemctl restart kubelet

# here to end for all node/worker installation




echo "================= init cluster on master ==================="


sudo kubeadm config images pull

sudo kubeadm init --pod-network-cidr=10.10.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


echo "==== Configure kubectl and Calico ===="
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O

sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml

#tell kubectl to create the resources defined in the custom-resources.yaml file
kubectl create -f custom-resources.yaml



#check nodes
kubectl get nodes
#make sure status are all correct
kubectl get cs
kubectl get pod -n kube-system


echo " ==================== start cluster ================"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-


echo " ==== check network config ===="

kubectl get pod -n kube-system 
# if coredns-xxxx keep ContainerCreating
kubectl describe pods -n kube-system coredns-xxxx





echo "==== run following command on master node==="
kubeadm token create --print-join-command

echo "==== worker join to master node ===="
sudo kubeadm join &lt;MASTER_NODE_IP>:&lt;API_SERVER_PORT> --token &lt;TOKEN> --discovery-token-ca-cert-hash &lt;CERTIFICATE_HASH>


#exe this command will generate cli for worker node
kubeadm token create --print-join-command




#deploy nginx ingress controller
kubectl apply -f https://raw:githubusercontent:com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.0/deploy/static/provider/cloud/deploy.yaml
