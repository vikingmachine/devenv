#!/bin/bash -e

mkdir -p ./build
cd ./build

docker system prune -a -f

echo Please enter your AWS Access Key ID:
read aws_access_key
echo Please enter your AWS Secret Access Key:
read aws_secret_key

echo 'Go to the "Create bless config-file (linux and mac)" section at this URL: https://int.basefarm.com/x/TgUWFw and copy the sections content and paste into your editori before saving it as the opened file.'
read -p 'Press [Enter] to open nano and save the config file automatically.' asd
tmp_bless_configfile=$(mktemp)
$EDITOR "$tmp_bless_configfile"
bless_conf="$(grep -v TEXT $tmp_bless_configfile)"

if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
   apt-get update
   apt install -y docker-ce
   systemctl enable docker
   groupadd docker
   usermod -aG docker $USER
fi


if [ -f "./packer" ]; then
    echo "Packer is already installed"
else
   wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
   unzip packer_1.3.2_linux_amd64.zip
fi

wget https://raw.githubusercontent.com/vikingmachine/devenv/master/build.json -O build.json
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/configure.sh -O configure.sh

PACKER_LOG=1 ./packer build -var "aws_access_key=$aws_access_key" -var "aws_secret_key=$aws_secret_key" -var "hostuser=$USER" -var "bless_conf=$bless_conf" build.json
cd ..

docker run --name bf-aws-dev -v /home/$USER/code:/root/code -it local:aws-dev /bin/bash
