#!/bin/bash -e

# Setup Basefarm Session Tools

apt update
apt -y install curl nano unzip wget openssl python python-pip openssh-client
pip install awscli --upgrade
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
wget https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
unzip terraform_0.11.8_linux_amd64.zip
echo 'source session-tool.sh' >>~/.bashrc
source ~/.bashrc
mv terraform session-tool.sh /usr/local/bin/
aws configure --profile awsops set aws_access_key_id $access_key
aws configure --profile awsops set aws_secret_access_key $secret_key
aws configure set default.session_tool_default_profile awsops
aws configure set session-tool_bucketname bf-aws-tools-session-tool --profile awsops
# get_session -d

#Setup BLESS for access to AWS servers.

eval `ssh-agent`
ssh-keygen -f ~/.ssh/blessid -b 4096 -t rsa -C 'Key for BLESS certificate' -N ''
ssh-keygen -y -f ~/.ssh/blessid > ~/.ssh/blessid.pub
touch ~/.ssh/blessid-cert.pub
ln -s ~/.ssh/blessid-cert.pub ~/.ssh/blessid-cert
