#!/bin/bash

set -e

sudo apt-get install -y postgresql libpq-dev

# Add user to database
sudo -u postgres psql --command "create role dev with password '1111' login createdb;"
