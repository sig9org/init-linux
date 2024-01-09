#!/bin/bash

dt_start=$( date +"%s" )

# Set the timezone
timedatectl set-timezone Asia/Tokyo

# Configure NTP servers
cat << EOF >> /etc/systemd/timesyncd.conf
NTP=162.159.200.123 162.159.200.1
EOF

# Update sshd
sed -i -e "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
sed -i -e "s/#ClientAliveCountMax 3/ClientAliveCountMax 5/g" /etc/ssh/sshd_config

# Disable SSH client warnings
cat << EOF > /etc/ssh/ssh_config.d/99_lab.conf
KexAlgorithms +diffie-hellman-group1-sha1
Ciphers aes128-cbc,aes256-ctr
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
EOF

# Disable AppArmor
systemctl stop apparmor.service
systemctl disable apparmor.service

# Customize the prompt display
cat << 'EOF' >> ~/.bashrc

# Modify the prompt.
if [ `id -u` = 0 ]; then
  PS1="\[\e[1;31m\]\u@\h \W\\$ \[\e[m\]"
else
  PS1="\[\e[1;36m\]\u@\h \W\\$ \[\e[m\]"
fi
EOF

# Disable welcome message
cat << EOF > ~/.hushlogin
exit
EOF

# Control needrestart
cat << 'EOF' > /etc/needrestart/conf.d/99_restart.conf
$nrconf{kernelhints} = '0';
$nrconf{restart} = 'a';
EOF

# Install basic packages
apt -y update
apt -y install \
    curl \
    fping \
	git \
	neovim \
    nmap \
    tree \
    unzip \
    zip

# NeoVim settings
cat << 'EOF' >> ~/.bashrc

# NeoVim settings
alias vi="nvim"
alias vim="nvim"
EOF

# Update system
apt -y upgrade

# Install uncmnt
curl -L https://github.com/sig9org/uncmnt/releases/download/v0.0.2/uncmnt_v0.0.2_linux_amd64 -o /usr/local/bin/uncmnt && \
chmod 755 /usr/local/bin/uncmnt

# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
cat << 'EOF' >> ~/.bashrc

# asdf settings
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
EOF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

asdf update

# Install direnv
asdf plugin add direnv
asdf install direnv 2.33.0
asdf global direnv 2.33.0
cat << 'EOF' >> ~/.bashrc

# direnv settings
export EDITOR=vim
eval "$(direnv hook bash)"
EOF

# venv & direnv initialization script
cat << 'EOF' > /usr/local/bin/venv
#!/bin/sh

python3 -m venv .venv
echo 'source .venv/bin/activate' > .envrc
direnv allow
.venv/bin/python3 -m pip install --upgrade pip
EOF
chmod 755 /usr/local/bin/venv

# Install golang
asdf plugin add golang
asdf install golang 1.21.5
asdf global golang 1.21.5

# Install Python
apt -y install \
  build-essential \
  curl \
  libbz2-dev \
  libffi-dev \
  liblzma-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libxml2-dev \
  libxmlsec1-dev \
  tk-dev \
  xz-utils \
  zlib1g-dev
asdf plugin add python
asdf install python 3.12.1
asdf global python 3.12.1

# Install Terraform
asdf plugin add terraform
asdf install terraform 1.6.6
asdf global terraform 1.6.6

# Reboot
dt_end=$( date +"%s" )
elapsed=$((dt_end - dt_start))
echo "##############################"
echo "Elapsed time: ${elapsed} seconds."
echo "##############################"
reboot
