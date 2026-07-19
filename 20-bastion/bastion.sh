#!/bin/bash
#increasing bastion /home folder volume for terraform purpose  
growpart /dev/nvme0n1 4
lvextend -l +100%FREE /dev/mapper/RootVG-varVol
xfs_growfs /var

#installing docker
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker 
systemctl enable docker 
usermod -aG docker ec2-user

#installing kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.3/2026-04-08/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH


#installing eksctl
ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl




cd /home/ec2-user
su - ec2-user -c '
  git clone https://github.com/AnuragBojja/eksctl.git
  cd eksctl 
  eksctl create cluster -f node.yaml
  cd ..

  echo "..."
  echo "..."
  echo "installing ebs drivers"
  kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.61"

  echo "..."
  echo "..."
  echo "installing kubectx"
  git clone https://github.com/ahmetb/kubectx.git
  cd kubectx
  chmod +x kubens
  sudo mv ./kubens /usr/local/bin
  cd ..

  echo "..."
  echo "..."
  echo "installing helm"
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
  chmod 700 get_helm.sh
  ./get_helm.sh

  echo "..."
  echo "..."
  echo "installing k9s"
  curl -sS https://webinstall.dev/k9s | bash
'
# cd docker-files
# docker compose up -d