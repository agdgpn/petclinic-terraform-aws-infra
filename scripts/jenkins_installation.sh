#!/bin/bash#!/bin/bash
# Install Jenkins and change the defaut port
# Run the script with port number argument to change the default port to this value
port=$1
if [ -x "$(command -v jenkins)" ]; then
  echo "Jenkins is already installed"
else
  echo 'Installing Jenkins step by step ...'
  sudo apt update -y
  sudo apt install openjdk-11-jdk-headless -y
  sudo apt update -y
  sudo apt install curl -y
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt update -y
  sudo apt-get install jenkins -y
  sudo systemctl start jenkins
  sudo systemctl enable --now jenkins
  echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
  sudo su jenkins
  # Jenkins config to set default port to $port.
  if [ $port ]
  then
    sudo sed -i -e 's/Environment="JENKINS_PORT=[0-9]\+"/Environment="JENKINS_PORT=$port"/' /usr/lib/systemd/system/jenkins.service
    sudo sed -i -e 's/^\s*#\s*AmbientCapabilities=CAP_NET_BIND_SERVICE/AmbientCapabilities=CAP_NET_BIND_SERVICE/' /usr/lib/systemd/system/jenkins.service
  fi
  sudo systemctl daemon-reload
  sudo systemctl restart jenkins
fi