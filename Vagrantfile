# -*- mode: ruby -*-
# vi: set ft=ruby :


$script = <<-SCRIPT
#!/bin/bash -xe

#0
apt-get update
#1
apt install -y docker.io socat jq mc
#2
which minikube || ( curl --silent -Lo minikube \
      https://github.com/kubernetes/minikube/releases/download/v1.5.2/minikube-linux-amd64 \
       && chmod +x minikube \
        && mv minikube /usr/local/bin/ )
#3
minikube update-context >/dev/null 2>&1 || true 
minikube status >/dev/null 2>&1 || minikube start --vm-driver=none \
       --apiserver-ips $(ifconfig | grep 'inet ' | awk '{print$2}' | tr '\n' ',' | sed 's/,$//g') \
       --apiserver-name localhost
which kubectl || ( minikube kubectl get po && \
       cp -vf /root/.minikube/cache/*/kubectl /usr/local/bin/ )
#4
mkdir -p /tmp/hostpath-provisioner /vagrant_data
chmod  777 /tmp/hostpath-provisioner /vagrant_data
cat /etc/fstab | grep -q '/tmp/hostpath-provisioner' || \
       echo "/vagrant_data /tmp/hostpath-provisioner none defaults,bind 0 2" \
        | tee -a /etc/fstab && mount -av     
#5
minikube addons enable ingress
minikube addons enable dashboard
sleep 10
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec":{"type":"NodePort","ports": [{ "port": 80, "nodePort": 30000 }]}}'
#6
which helm || ( curl --silent -LO https://get.helm.sh/helm-v2.16.0-linux-amd64.tar.gz \
      && tar -xf helm-v2.16.0-linux-amd64.tar.gz  \
       && sudo mv -f linux-amd64/helm  /usr/local/bin/ \
        && rm -r helm-v2.16.0-linux-amd64.tar.gz linux-amd64 \
         && sudo chmod +x /usr/local/bin/helm ) 
helm ls || helm init || true
while ( ! helm ls >/dev/null 2>&1 ); do sleep 10 && echo 'Waiting for tiller...';  done 
#7
cat > jenkins.yaml << 'EOF'
---
master:
  containerEnv:
    - name: DOCKER_HOST
      value: "tcp://127.0.0.1:2375"
    - name: PATH
      value: "/usr/local/openjdk-8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/jenkins_home/tools"
    - name: HOME
      value: "/var/jenkins_home"

  jenkinsOpts: "-Dpermissive-script-security.enabled=no_security"
  numExecutors: 4
  ingress:
    enabled: false
  useSecurity: false
  serviceType: NodePort
  nodePort: 30080
  installPlugins:
    - ace-editor:1.1
    - antisamy-markup-formatter:1.6
    - apache-httpcomponents-client-4-api:4.5.10-2.0
    - authentication-tokens:1.3
    - bouncycastle-api:2.17
    - branch-api:2.5.4
    - cloudbees-folder:6.9
    - command-launcher:1.3
    - credentials-binding:1.20
    - credentials:2.3.0
    - display-url-api:2.3.2
    - docker-commons:1.15
    - docker-java-api:3.0.14
    - docker-plugin:1.1.8
    - docker-slaves:1.0.7
    - docker-workflow:1.21
    - durable-task:1.32
    - git-client:2.9.0
    - git-server:1.8
    - git:3.12.1
    - handlebars:1.1.1
    - jackson2-api:2.10.0
    - jdk-tool:1.3
    - jquery-detached:1.2.1
    - jsch:0.1.55.1
    - junit:1.28
    - kubernetes-client-api:4.6.0-2
    - kubernetes-credentials:0.4.1
    - kubernetes:1.20.2
    - lockable-resources:2.6
    - mailer:1.29
    - matrix-project:1.14
    - mock-slave:1.13
    - momentjs:1.1.1
    - pipeline-build-step:2.9
    - pipeline-graph-analysis:1.10
    - pipeline-input-step:2.11
    - pipeline-milestone-step:1.3.1
    - pipeline-model-api:1.3.9
    - pipeline-model-declarative-agent:1.1.1
    - pipeline-model-definition:1.3.9
    - pipeline-model-extensions:1.3.9
    - pipeline-rest-api:2.12
    - pipeline-stage-step:2.3
    - pipeline-stage-tags-metadata:1.3.9
    - pipeline-stage-view:2.12
    - plain-credentials:1.5
    - resource-disposer:0.14
    - scm-api:2.6.3
    - script-security:1.66
    - ssh-credentials:1.18
    - ssh-slaves:1.31.0
    - structs:1.20
    - token-macro:2.10
    - trilead-api:1.0.5
    - uno-choice:2.2.1
    - variant:1.3
    - workflow-aggregator:2.6
    - workflow-api:2.37
    - workflow-basic-steps:2.18
    - workflow-cps-global-lib:2.15
    - workflow-cps:2.74
    - workflow-durable-task-step:2.34
    - workflow-job:2.35
    - workflow-multibranch:2.21
    - workflow-scm-step:2.9
    - workflow-step-api:2.20
    - workflow-support:3.3
    - ws-cleanup:0.37
    - permissive-script-security:0.5
  scriptApproval:
    - field hudson.model.UpdateSite$Entry name
    - field hudson.model.UpdateSite$Entry version
    - method groovy.json.JsonSlurper parse java.io.InputStream
    - method groovy.lang.GroovyObject invokeMethod java.lang.String java.lang.Object
    - method hudson.PluginManager getPlugins
    - method hudson.PluginWrapper getInfo
    - method hudson.XmlFile getFile
    - method hudson.model.AbstractItem getConfigFile
    - method hudson.model.Item getFullName
    - method hudson.model.Item getName
    - method hudson.model.ItemGroup getAllItems
    - method hudson.model.ItemGroup getItem java.lang.String
    - method hudson.model.ItemGroup getItems
    - method hudson.model.Saveable save
    - method hudson.slaves.EnvironmentVariablesNodeProperty getEnvVars
    - method hudson.util.PersistedList getAll java.lang.Class
    - method java.io.File mkdir
    - method jenkins.model.Jenkins getGlobalNodeProperties
    - method jenkins.model.Jenkins getPluginManager
    - method jenkins.model.ModifiableTopLevelItemGroup copy hudson.model.TopLevelItem java.lang.String
    - method jenkins.model.ParameterizedJobMixIn setDisabled boolean
    - method org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval getApprovedSignatures
    - new hudson.slaves.EnvironmentVariablesNodeProperty hudson.slaves.EnvironmentVariablesNodeProperty$Entry[]
    - new java.io.File java.lang.String
    - staticField java.io.File separator
    - staticMethod groovy.util.Eval me java.lang.String
    - staticMethod java.lang.System getProperty java.lang.String
    - staticMethod jenkins.model.Jenkins getInstance
    - staticMethod org.apache.commons.io.IOUtils toInputStream java.lang.String
    - staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods execute java.lang.String
    - staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods execute java.util.List
    - staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getText java.io.File
    - staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods grep java.util.List java.lang.Object
    - staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods leftShift java.io.File java.lang.Object
    - staticMethod org.codehaus.groovy.runtime.ProcessGroovyMethods getText java.lang.Process
    - staticMethod org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval get
  sidecars:
    other:
        - name: dind
          image:  docker:dind
          env:
          - name: DOCKER_TLS_CERTDIR
            value: ''
          securityContext:
            privileged: true
---
EOF
#8
helm repo update
helm upgrade --namespace kube-system -i -f jenkins.yaml jenkins stable/jenkins
#9
jpvc=/tmp/hostpath-provisioner/$(kubectl -n kube-system get pvc jenkins |grep -oP "pvc-[\-0-9a-z]+")
mkdir -p ${jpvc}/{tools,.kube}
cp -vf /usr/local/bin/{kubectl,helm} ${jpvc}/tools/
cp -vf /usr/bin/docker ${jpvc}/tools/
set +x
[ -f  ${jpvc}/.kube/config  ] || \
    cat ~/.kube/config | while IFS=  read line; do 
     if ( echo "$line" | grep -q -E 'certificate-authority|client-certificate|client-key' ); then
      echo "$line" | awk -F':' '{system("echo \\""$1"-data\\": $(base64 "$2 "| tr -d \\"\\\\n\\")")}'
     else
      echo "$line"
     fi
done | sed 's@server:.*@server: https://kubernetes.default@g' | tee -a ${jpvc}/.kube/config

cat ~/.kube/config | while IFS=  read line; do
   if ( echo "$line" | grep -q -E 'certificate-authority|client-certificate|client-key' ); then
      echo "$line" | awk -F':' '{system("echo \\""$1"-data\\": $(base64 "$2 "| tr -d \\"\\\\n\\")")}'
   else
      echo "$line"
   fi
done > ~/kubeconfig


SCRIPT



Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu1804"
  #config.vm.hostname = "service01"
  
  config.vm.box_check_update = false

  config.vm.network "public_network", use_dhcp_assigned_default_route: true, bridge: "enp5s0.5"

  config.vm.synced_folder "./vagrant_data", "/vagrant_data"
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

