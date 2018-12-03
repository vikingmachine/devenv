#!/bin/bash -e


# Setup Basefarm Session Tools

terraver=0.11.10

apt update
apt -y install curl nano unzip wget openssl python python-pip openssh-client git python-virtualenv gcc sudo kpcli
pip install awscli --upgrade
wget https://releases.hashicorp.com/terraform/"$terraver"/terraform_"$terraver"_linux_amd64.zip
wget https://raw.githubusercontent.com/basefarm/aws-session-tool/master/session-tool.sh
unzip terraform_"$terraver"_linux_amd64.zip

useradd -s /bin/bash -m -g root -G sudo $HOSTUSER
echo "$HOSTUSER:password" | sudo chpasswd


#Setup terraform and AWS CLI / Session tools

mv terraform session-tool.sh /usr/local/bin/
rm -rf terraform*
echo "$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY_ID" >> ~/.secrets.csv



#Configure .bashrc alias and for session tools script + bless ssh-agent to run on boot.

mv ~/.bashrc ~/.bashrc.default
cat <<TEXT >> ~/.bashrc
. ~/.bashrc.default
alias sshprod="ssh -A $HOSTUSER@linbast.transhub.io"
alias sshstage="ssh -A $HOSTUSER@linbast.stage.transhub.io"
alias sshtest="ssh -A $HOSTUSER@linbast.test.transhub.io"
alias bless="/opt/awsops/python-blessclient/blessclient.run"
source /usr/local/bin/session-tool.sh
get_session -i "/root/.secrets.csv" -b "bf-aws-tools-session-tool" -d


TEXT

echo 'eval `ssh-agent`' >> ~/.bashrc



# Setup Bless.
mkdir /opt/awsops && cd /opt/awsops
git clone https://github.com/lyft/python-blessclient.git && cd python-blessclient && make client
sed -i "s/default='iad'/default='EU'/" blessclient/client.py
cp blessclient.cfg.sample blessclient.cfg

#Create bless config
echo "$bless_conf" > /opt/awsops/python-blessclient/blessclient.cfg

#Create keys for Bless and Github
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
