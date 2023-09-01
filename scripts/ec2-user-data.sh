#!/bin/bash -xe
# 1. Java installation - Java is required for jenkins agents
if [ -x "$(command -v java)" ]; then
    echo "Java is already installed"
else
  apt update -y
  max_retry=5 # Max retry for the following commands
  counter=0   # Initial retry counter value
  until apt install openjdk-17-jre-headless -y
  do
    apt update -y
    sleep 1
    [[ counter -eq $max_retry ]] && echo "Failed!" && break
    echo "Trying again. Try #$counter"
    ((counter++))
  done
fi

# 2. Docker installation - Docker is required for jenkins agents for build & push steps
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
    echo "Installing docker ..."
    # Docker installation commands
    apt-get update -y
    max_retry=5 # Max retry for the following commands
    counter=0   # Initial retry counter value
    until apt-get install ca-certificates curl gnupg -y
    do
        sleep 1
        [[ counter -eq $max_retry ]] && echo "Failed!" && break
        echo "Trying again. Try #$counter"
        ((counter++))
    done
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt update -y
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
fi

# Mysql client installation
if [ -x "$(command -v mysql)" ]; then
    echo "Mysql-client is already installed"
else
  apt update -y
  max_retry=5 # Max retry for the following commands
  counter=0   # Initial retry counter value
  until apt install mysql-client -y
  do
    sleep 1
    [[ counter -eq $max_retry ]] && echo "Failed!" && break
    echo "Trying again. Try #$counter"
    ((counter++))
  done
fi

# 3. Create jenkins user on jenkins agent 

usr=jenkins
check=$(id -u $usr &2>/dev/null)
if [ $check ]
then
    echo "user $usr already exists"
else
  echo "creating user $usr ..."
  # Creation user
  adduser --disabled-password --shell /bin/bash --gecos "User" $usr
  # Desactivation password user jenkins
  passwd -d $usr
  # Autoriser le user par defaut (ubuntun) les droits sur le répertoire /home/jenkins/
  chown -R ubuntu:ubuntu /home/jenkins/
fi
# 4. Docker configuration after docker installation - Add ubuntu user to docker group
usr=ubuntu
echo "Adding user $usr in docker group ..."
usermod -aG docker $usr # Add ubuntu user to docker group
newgrp docker
# 5. REBOOT
reboot