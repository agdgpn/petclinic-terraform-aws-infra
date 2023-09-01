#!/bin/bash
# Docker installation - Docker is required for jenkins agents for build & push steps
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
    echo "Installing docker ..."
    # Updat before running docker installation commands
    apt-get update -
    
    max_retry=5 # Max retry for the following command
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
    
    max_retry=5 # Max retry for the following command
    counter=0   # Initial retry counter value
    until apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    do
        sleep 1
        [[ counter -eq $max_retry ]] && echo "Failed!" && break
        echo "Trying again. Try #$counter"
        ((counter++))
    done
fi