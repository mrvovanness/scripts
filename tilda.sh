#!/bin/bash
# run this in usr/local/src
sudo apt-get install libconfuse-dev libvte-dev libglade2-dev flex &&
curl -L http://sourceforge.net/projects/tilda/files/tilda/tilda-0.9.6/tilda-0.9.6.tar.gz/download | tar xvz &&
cd tilda-0.9.6 &&
curl -L http://sourceforge.net/p/tilda/patches/_discuss/thread/45eadc01/df46/attachment/tilda-0.9.6-palette.diff.gz | gunzip | sudo patch -p0 &&
./configure
make
sudo make install
