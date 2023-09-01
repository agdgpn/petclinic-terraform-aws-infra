#!/bin/bash
# Java installation - Java is required for jenkins agents
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