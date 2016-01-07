#!/bin/sh
wget -O ~/redis.tar.gz http://download.redis.io/releases/redis-3.0.3.tar.gz &&
tar xzfv ~/redis.tar.gz --directory ~/ &&
cd ~/redis-3.0.3
make
# src/redis-server
