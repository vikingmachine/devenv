#!/bin/bash -e

# Install required packaged
apt update
apt -y install curl nano unzip wget groff openssl python python-pip python3 python3-pip openssh-client git python-virtualenv gcc sudo kpcli

# Setup AWS CLI
mkdir -p "$HOME/.aws/"
pip install awscli --upgrade

# Setup terraform
terraver=0.11.10
wget --no-dns-cache --no-cache https://releases.hashicorp.com/terraform/"$terraver"/terraform_"$terraver"_linux_amd64.zip
unzip terraform_"$terraver"_linux_amd64.zip
mv terraform /usr/local/bin/
rm -rf terraform*

# Setup Basefarm Session Tools
wget --no-dns-cache --no-cache https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
mv session-tool.sh /usr/local/bin/
echo "$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY_ID" >> ~/.secrets.csv

# Setup Bless.
pip3 install git+https://github.com/basefarm/python-blessclient.git --upgrade

#Create bless config
echo "$BLESS_CONF" > "$HOME/.aws/blessclient.cfg"

# Create keys for Bless and Github
ssh-keygen -f ~/.ssh/blessid -b 4096 -t rsa -C 'Key for BLESS certificate' -N ''
ssh-keygen -y -f ~/.ssh/blessid > ~/.ssh/blessid.pub
touch ~/.ssh/blessid-cert.pub
ln -s ~/.ssh/blessid-cert.pub ~/.ssh/blessid-cert
ssh-keygen -f ~/.ssh/github_rsa -b 4096 -t rsa -C 'Basefarm Github key' -N ''

# Make sure that you don't get SSH warnings when logging in to a bastion server (as they sit behind a load balancer)
touch ~/.ssh/config
cat > ~/.ssh/config <<"TEXT"
Host *.transhub.io
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ServerAliveInterval 50
  User "$HOSTUSER"

Host github.com
  User git
  Hostname github.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/github_rsa
TEXT

# Configure .bashrc alias and for session tools script + bless ssh-agent to run on boot.
mv ~/.bashrc ~/.bashrc.default
cat <<TEXT >> ~/.bashrc
. ~/.bashrc.default
alias sshprod="ssh -A $HOSTUSER@linbast.transhub.io"
alias sshstage="ssh -A $HOSTUSER@linbast.stage.transhub.io"
alias sshtest="ssh -A $HOSTUSER@linbast.test.transhub.io"

if [ "x$(aws configure get region)" == "x" ]; then
  echo "Setting region."
  aws configure set region "eu-west-1"
else
  echo "AWS region already set."
fi

eval `ssh-agent`
source /usr/local/bin/session-tool.sh
get_session -i "/root/.secrets.csv" -b "bf-aws-tools-session-tool" -d

complete -C '/usr/local/bin/aws_completer' aws
TEXT
