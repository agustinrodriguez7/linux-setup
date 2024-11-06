go_version=go1.23.2
nvm_version=v0.40.0
node_version=22
clear

install_node () {
  echo "--------- Installing Node ---------"
  # installs nvm (Node Version Manager)
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh | bash

  # This enable to run NVM without need to restart the terminal
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  # download and install Node.js (you may need to restart the terminal)
  nvm install $node_version
}

install_docker () {
  echo "--------- Installing Docker ---------"
  # Add Docker's official GPG key:
  sudo apt-get -y update
  sudo apt-get -y install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  # It's designed to run in linux mint, but if it's running on ubuntu, change UBUNTU_CODENAME for VERSION_CODENAME
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get -y update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_golang () {
  echo "--------- Installing Golang ---------"
  curl -LO https://go.dev/dl/$go_version.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf $go_version.linux-amd64.tar.gz
  sudo bash -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile'
  rm -rf $go_version.linux-amd64.tar.gz
}

install_kubectl () {
  echo "--------- Installing kubectl ---------"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

install_git () {
  sudo apt-get -y update
  sudo apt-get -y install git
}

install_aws_cli () {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip
}

install_terraform () {
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg -y --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform

}

if [ "$#" -eq 0 ]; then
  echo "No parameters were passed."
  echo "Try to add a parameter like this: \"sh installation.sh golang node\""
else
  #This helps to run all the sudo commands
  sudo -v
for param in "$@"
  do
    if [ "$param" = "node" ];
    then
      install_node

    elif [ "$param" = "docker" ];
    then
      install_docker

    elif [ "$param" = "golang" ];
    then
      install_golang

    elif [ "$param" = "kubectl" ];
    then
      install_kubectl

    elif [ "$param" = "git" ];
    then
      install_git

    elif [ "$param" = "aws_cli" ];
    then
      install_aws_cli

    elif [ "$param" = "terraform" ];
    then
      install_terraform
    fi
  done

echo "----- IMPORTANT -----"
echo "Close session to apply this changes"
fi
