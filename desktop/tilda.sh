#!/bin/bash

set -e
sudo apt-get install -y dh-autoreconf autotools-dev debhelper dh-autoreconf libconfuse-dev libgtk-3-dev libvte-2.91-dev pkg-config gettext automake autoconf autopoint
git clone https://github.com/lanoxx/tilda.git ~/tilda
cd ~/tilda &&
./autogen.sh --prefix=/usr &&
make &&
sudo make install
