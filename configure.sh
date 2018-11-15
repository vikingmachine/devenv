#!/bin/bash -i

# Setup Basefarm Session Tools

apt update
apt -y install curl nano unzip wget openssl python python-pip openssh-client git python-virtualenv gcc
pip install awscli --upgrade
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
wget https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
unzip terraform_0.11.8_linux_amd64.zip
echo 'source session-tool.sh' >>~/.bashrc
echo 'eval `ssh-agent`' >>~/.bashrc
source ~/.bashrc
mv terraform session-tool.sh /usr/local/bin/
echo "$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY_ID" >> /root/secrets.csv
#aws configure --profile awsops set aws_access_key_id $AWS_ACCESS_KEY_ID
#aws configure --profile awsops set aws_secret_access_key $AWS_SECRET_ACCESS_KEY_ID
#aws configure set default.session_tool_default_profile awsops
#aws configure set session-tool_bucketname bf-aws-tools-session-tool --profile awsops
#source /usr/local/bin/session-tool.sh
#get_session -i /root/secrets.csv -b bf-aws-tools-session-tool -d

# Setup BLESS
eval `ssh-agent`
mkdir /opt/awsops && cd /opt/awsops
git clone https://github.com/lyft/python-blessclient.git && cd python-blessclient && make client
sed -i "s/default='iad'/default='EU'/" blessclient/client.py
cp blessclient.cfg.sample blessclient.cfg


ssh-keygen -f ~/.ssh/blessid -b 4096 -t rsa -C 'Key for BLESS certificate' -N ''
ssh-keygen -y -f ~/.ssh/blessid > ~/.ssh/blessid.pub
touch ~/.ssh/blessid-cert.pub
ln -s ~/.ssh/blessid-cert.pub ~/.ssh/blessid-cert


cat > blessclient.cfg <<"TEXT"
[MAIN]
region_aliases: EU,US
kms_service_name: bless-bfops
# Ips only accepted by ruter
bastion_ips: 10.237.22.0/24,10.237.23.0/24,10.237.24.0/24,10.237.38.0/24,10.237.39.0/24,10.237.40.0/24,10.237.6.0/24,10.237.7.0/24,10.237.8.0/24
ca_backend: bless
  
[CLIENT]
domain_regex: (.*\.example\.com|.*\.example\.net|\A10\.100(?:\.[0-9]{1,3}){2}\Z)$
cache_dir: .bless/session
cache_file: bless_cache.json
mfa_cache_dir: .aws/session
mfa_cache_file: token_cache.json
ip_urls: http://api.ipify.org, http://canihazip.com
update_script: /dev/null
  
[LAMBDA]
user_role: BLESS-invoke-bfops
# Our AWSops account
account_id: 564070118781
functionname: BLESS-bfops
functionversion: $LATEST
certlifetime: 43200
ipcachelifetime: 120
timeout_connect: 5
timeout_read: 10
  
[REGION_EU]
awsregion: eu-west-1
kmsauthkey: b1c61250-09eb-47dd-ae3a-5aa60ade0599
   
   
[REGION_US]
awsregion: us-east-1
kmsauthkey: ea0267c7-6bed-48a0-ad9d-d23148c0cea9
  
TEXT



