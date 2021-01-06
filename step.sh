#!/bin/bash
set -x

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then

  echo "Adding universe repository to apt-get"
  sudo add-apt-repository "deb http://cz.archive.ubuntu.com/ubuntu cosmic main universe"

  echo "Update repositories, installing ppp and openfortivpn"
  sudo apt-get install -y ppp
  wget https://launchpad.net/~ar-lex/+archive/ubuntu/fortisslvpn/+build/13602424/+files/openfortivpn_1.5.0-1ppa2~artful_amd64.deb
  dpkg -i openfortivpn_1.5.0-1ppa2~artful_amd64.deb
  sudo apt-get update
  echo "done updates"

else

  echo "Installing openfortivpn on MacOS"
  brew install -y openfortivpn

fi

echo "Starting VPN connection with gateways - ${host}:${port}"
sudo nohup openfortivpn ${host}:${port} --password=${password} --username=${username} --trusted-cert ${trusted_cert} &> $BITRISE_DEPLOY_DIR/logs.txt &

echo "Waiting connection"
NUMBER_OF_RETRY=0
until fgrep -q "INFO:   Tunnel is up and running." $BITRISE_DEPLOY_DIR/logs.txt || [ $NUMBER_OF_RETRY -eq 7 ]; do
  ((NUMBER_OF_RETRY++))
  cat $BITRISE_DEPLOY_DIR/logs.txt
  sleep 1;
done
