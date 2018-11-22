#!/bin/bash -e

docker system prune -a -f

echo Please enter your AWS Access Key ID:
read aws_access_key
echo Please enter your AWS Secret Access Key:
read aws_secret_key


if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
   apt-get update
   apt install -y docker-ce
   systemctl enable docker
   groupadd docker
   usermod -aG docker $USER
fi


if [ -x "$(command -v packer)" ]; then
    echo "Packer is already installed"
else
   wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
   unzip packer_1.3.2_linux_amd64.zip
   mv packer /usr/local/bin/
fi



wget https://raw.githubusercontent.com/vikingmachine/devenv/master/build.json
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/configure.sh

PACKER_LOG=1 packer build -var "aws_access_key=$aws_access_key" -var "aws_secret_key=$aws_secret_key" -var "hostuser=$USER" build.json
docker run --name bf-aws-dev -v /home/$USER/code:/root/code -it local:aws-dev /bin/bash
