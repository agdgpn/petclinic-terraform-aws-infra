#!/bin/bash
# Create a user whithout password and give rw right to the default user (ubuntu)
usr=$1
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