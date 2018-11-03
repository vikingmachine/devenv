#!/bin/bash

wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
wget https://raw.githubusercontent.com/vikingmachine/devenv/master/build.json
unzip packer_1.3.2_linux_amd64.zip
sudo mv packer /usr/local/bin/
packer build build.json
docker run --name dev -it $USER

