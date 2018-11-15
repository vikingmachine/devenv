#!/bin/bash

echo Please enter your AWS Access Key ID:
read aws_access_key
echo Please enter your AWS Secret Access Key:
read aws_secret_key


if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   sudo systemctl enable docker
fi


if [ -x "$(command packer -v)" ]; then
    echo "Packer is already installed"
else
   wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
   unzip packer_1.3.2_linux_amd64.zip
   sudo mv packer /usr/local/bin/
fi



wget https://raw.githubusercontent.com/vikingmachine/devenv/master/build.json
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/configure.sh

sudo PACKER_LOG=1 packer build -var "aws_access_key=$aws_access_key" -var "aws_secret_key=$aws_secret_key" build.json
sudo docker run --name bf-aws-dev -it local:aws-dev /bin/bash -c "get_session -i /root/secrets.csv -b bf-aws-tools-session-tool -d"

