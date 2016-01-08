#! /bin/bash
wget -O dropbox.tar.gz "http://www.dropbox.com/download/?plat=lnx.x86_64"
tar -tzf dropbox.tar.gz # sanity check
tar -xvzf dropbox.tar.gz # extract to .dropbox-dist
echo $LANG # make sure that env variable lang is set
./dropbox-dist/dropboxd # run GUI Dropbox setup
