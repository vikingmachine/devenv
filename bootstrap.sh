#!/bin/bash

echo Please enter your AWS Access Key ID:
read aak
echo Please enter your AWS Secret Access Key:
read asak

export AWS_ACCESS_KEY_ID="$aak"
export AWS_SECRET_ACCESS_KEY="$asak"


if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
   curl -fsSL https://get.docker.com -o get-docker.sh
fi


sh get-docker.sh
sudo systemctl enable docker
wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/build.json
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/configure.sh
unzip packer_1.3.2_linux_amd64.zip
sudo mv packer /usr/local/bin/
sudo PACKER_LOG=1 packer build build.json
sudo docker run --name dev -it local:aws-dev

