#! /bin/bash
wget https://github.com/papertrail/remote_syslog2/releases/download/v0.14/remote_syslog_linux_amd64.tar.gz &&
tar xzfv ./remote_syslog*.tar.gz &&
cd remote_syslog
sudo cp ./remote_syslog /usr/local/bin
sudo touch /etc/log_files.yml
