#!/bin/sh

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
    PS1="[\[\033[1;31m\]\u@\h\[\033[00m\] \W]\\$ "
else
    PS1="[\[\033[1;36m\]\u@\h\[\033[00m\] \W]\\$ "
fi
EOF

# Disable welcome message
cat << EOF > ~/.hushlogin
exit
EOF

# Install direnv
curl -L https://github.com/direnv/direnv/releases/download/v2.31.0/direnv.linux-amd64 -o /usr/local/bin/direnv && \
chmod 755 /usr/local/bin/direnv

cat << 'EOF' >> ~/.bashrc
export EDITOR=vim
eval "$(direnv hook bash)"
EOF

# Install uncmnt
curl -L https://github.com/sig9org/uncmnt/releases/download/v0.0.2/uncmnt_v0.0.2_linux_amd64 -o /usr/local/bin/uncmnt && \
chmod 755 /usr/local/bin/uncmnt

# Control needrestart
cat << 'EOF' > /etc/needrestart/conf.d/99_restart.conf
$nrconf{kernelhints} = '0';
$nrconf{restart} = 'a';
EOF

# Install basic packages
apt -y update
apt -y install \
    fping \
    nmap \
    python3-pip \
    python3.10-venv \
    tree \
    unzip \
    zip

# Update system
apt -y upgrade

# Reboot
reboot
