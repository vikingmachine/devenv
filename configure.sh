#!/bin/bash -e

apt update,
apt -y install curl nano unzip wget openssl python3 python3-pip
pip3 install awscli --upgrade
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
wget https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
unzip terraform_0.11.8_linux_amd64.zip
echo 'source session-tool.sh' >>~/.bashrc
mv terraform session-tool.sh /usr/local/bin/
aws configure --profile awsops set aws_access_key_id {{user `aws_access_key`}}
aws configure --profile awsops set aws_secret_access_key {{user `aws_secret_key`}}
aws configure set default.session_tool_default_profile awsops
aws configure set session-tool_bucketname bf-aws-tools-session-tool --profile awsops
get_session -d
