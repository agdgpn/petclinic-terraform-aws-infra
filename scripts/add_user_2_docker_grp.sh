#!/bin/bash
# Docker configuration after docker installation - Add ubuntu user to docker group
usr=$1
echo "Adding user $usr in docker group ..."
usermod -aG docker $usr # Add ubuntu user to docker group
newgrp docker
