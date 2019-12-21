# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
#!/bin/bash -xe
# variables
k8s_version="v1.16.2"
helm_version="v2.16.1"
minikube_version="v1.6.2"

#0
apt-get update
#1
apt install -y docker.io socat jq mc
#2
which minikube || ( curl --silent -Lo minikube \
      https://github.com/kubernetes/minikube/releases/download/${minikube_version}/minikube-linux-amd64 \
       && chmod +x minikube \
        && mv minikube /usr/local/bin/ )
#3
mkdir -p /tmp/hostpath-provisioner /vagrant_data
chmod  777 /tmp/hostpath-provisioner /vagrant_data
cat /etc/fstab | grep -q '/tmp/hostpath-provisioner' || \
       echo "/vagrant_data /tmp/hostpath-provisioner none defaults,bind 0 2" \
        | tee -a /etc/fstab && mount -av     
#4
minikube update-context >/dev/null 2>&1 || true 
minikube status >/dev/null 2>&1 || minikube start --vm-driver=none --kubernetes-version=${k8s_version} \
       --apiserver-ips $(ifconfig | grep 'inet ' | awk '{print$2}' | tr '\n' ',' | sed 's/,$//g') \
       --apiserver-name localhost
which kubectl || ( minikube kubectl get po && \
       cp -vf /root/.minikube/cache/*/kubectl /usr/local/bin/ )
systemctl enable kubelet
#5
minikube addons enable ingress
minikube addons enable dashboard
sleep 10
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec":{"type":"NodePort","ports": [{ "port": 80, "nodePort": 30000 }]}}'
#6
which helm || ( curl --silent -LO https://get.helm.sh/helm-${helm_version}-linux-amd64.tar.gz \
      && tar -xf helm-*-linux-amd64.tar.gz  \
       && sudo mv -f linux-amd64/helm  /usr/local/bin/ \
        && rm -r helm-*-linux-amd64.tar.gz linux-amd64 \
         && sudo chmod +x /usr/local/bin/helm ) 
helm ls || helm init || true
while ( ! helm ls >/dev/null 2>&1 ); do sleep 10 && echo 'Waiting for tiller...';  done 
#7
helm repo update
helm install stable/prometheus-operator --version=8.3.3 --name=monitoring \
        --namespace=monitoring --values=minikube-prom-stack.yaml
#
SCRIPT



Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu1804"
  #config.vm.hostname = "service01"
  
  config.vm.box_check_update = false

  config.vm.network "public_network", use_dhcp_assigned_default_route: true, bridge: "vagrant0"

  config.vm.synced_folder "./vagrant_data", "/vagrant_data"  
  config.vm.provision "file", source: "minikube-prom-stack.yaml", destination: "minikube-prom-stack.yaml"  
  #config.vm.synced_folder "/etc/letsencrypt", "/etc/letsencrypt"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
  
    # Customize the amount of memory on the VM:
    vb.memory = "10000"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
  end


  config.vm.provision "shell", inline: $script

end
