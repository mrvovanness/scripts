# bootstraping local debian machine

#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -e
set -x

function install {
  echo installing $1
  shift
  apt-get -y install $@ > /dev/null 2> errors.txt
}

echo "update sources list"
cat debian-repos.list > /etc/apt/sources.list
