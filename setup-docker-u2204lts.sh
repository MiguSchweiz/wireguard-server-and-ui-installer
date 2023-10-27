#!/bin/bash

#noninteractive env
export DEBIAN_FRONTEND=noninteractive
echo 'APT::Get::Assume-Yes "true";' > /tmp/_tmp_apt.conf
export APT_CONFIG=/tmp/_tmp_apt.conf

#update
apt-get update && apt-get upgrade

#firewall
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 51820

#bandwith limiting
#tc qdisc change dev eth0 root tbf rate 800Mbit burst 16Mbit latency 1ms

#linode-cli
apt install python3-pip
pip3 install linode-cli

#export LINODE_CLI_TOKEN=<token>

#git
apt install git gh

#Docker
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-compose

#wireguard-ui-plus
apt install wireguard-tools
cd
git clone https://github.com/MiguSchweiz/wireguard-ui-plus.git
cd wireguard-ui-plus
git config --global user.email "user@domain"
git config --global user.name "Name"

docker compose build --build-arg=GIT_COMMIT=$(git rev-parse --short HEAD)
docker-compose up &
sleep 2
docker update --restart unless-stopped wgui
cd

#iptables
apt install iptables-persistent
iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
iptables-save > /etc/iptables/rules.v6

#.bashrc
echo "alias ci='git commit  -a -m \"-\";git push'">>.bashrc

echo "alias gp='cd /root/wireguard-ui-plus;git pull;docker stop wgui; cat ../StackScript |egrep \"docker|sleep\"|egrep -v \"apt|curl\" |xargs -0 -t /bin/bash -c'">>.bashrc

#utils
apt install speedtest-cli

#set github credentials via: gh auth login
reboot








