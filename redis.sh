#!/bin/sh
wget http://download.redis.io/releases/redis-3.0.3.tar.gz &&
tar xzf redis-3.0.3.tar.gz &&
cd redis-3.0.3
make
# src/redis-server
