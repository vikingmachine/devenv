#!/bin/bash

wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
unzip packer_1.3.2_linux_amd64.zip
mv packer /usr/sbin/
packer build build.json
docker run --name dev -i -t ewilliams:ewilliams

