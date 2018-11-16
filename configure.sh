#!/bin/bash -e

# Setup Basefarm Session Tools

apt update
apt -y install curl nano unzip wget openssl python python-pip openssh-client git python-virtualenv gcc
pip install awscli --upgrade
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
wget https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
unzip terraform_0.11.8_linux_amd64.zip

#Configure .bashrc alias and for session tools script + bless ssh-agent to run on boot.


cat <<TEXT >> ~/.bashrc
alias prod="ssh -A $HOSTUSER@linbast.transhub.io"
alias stage="ssh -A $HOSTUSER@linbast.stage.transhub.io"
alias test="ssh -A $HOSTUSER@linbast.test.transhub.io"
alias bless="/opt/awsops/python-blessclient/blessclient.run"
source session-tool.sh
eval `ssh-agent`
TEXT
 


#Setup terraform and AWS CLI / Session tools

mv terraform session-tool.sh /usr/local/bin/
echo "$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY_ID" >> /root/secrets.csv
#aws configure --profile awsops set aws_access_key_id $AWS_ACCESS_KEY_ID
#aws configure --profile awsops set aws_secret_access_key $AWS_SECRET_ACCESS_KEY_ID
#aws configure set default.session_tool_default_profile awsops
#aws configure set session-tool_bucketname bf-aws-tools-session-tool --profile awsops
#source /usr/local/bin/session-tool.sh
#get_session -i /root/secrets.csv -b bf-aws-tools-session-tool -d


# Setup Bless. This is missing the config of blessclient.cfg. Do that step manually for now

mkdir /opt/awsops && cd /opt/awsops
git clone https://github.com/lyft/python-blessclient.git && cd python-blessclient && make client
sed -i "s/default='iad'/default='EU'/" blessclient/client.py
cp blessclient.cfg.sample blessclient.cfg
eval `ssh-agent`

#Setup keys for Bless.

ssh-keygen -f ~/.ssh/blessid -b 4096 -t rsa -C 'Key for BLESS certificate' -N ''
ssh-keygen -y -f ~/.ssh/blessid > ~/.ssh/blessid.pub
touch ~/.ssh/blessid-cert.pub
ln -s ~/.ssh/blessid-cert.pub ~/.ssh/blessid-cert

# Make sure that you don't get SSH warnings when logging in to a bastion server (as they sit behind a load balancer)
touch ~/.ssh/config 
cat > ~/.ssh/config <<"TEXT"

Host *.transhub.io
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null
	ServerAliveInterval 50
	User $HOSTUSER

TEXT


