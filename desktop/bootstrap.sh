
# bootstraping local debian machine

#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -e

user=dev

print_status() {
  echo
  echo "## $1"
  echo
}

rescue() {
  echo "Error executing command, exiting"
  exit 1
}

exec_cmd_success() {
  echo "++ $1"
  bash -c "$1"
}

exec_cmd() {
  exec_cmd_success "$1" || rescue
}

install() {
  echo "## installing $1"
  shift
  apt-get -y install $@
}

# Progress file
if [ ! -f $HOME/.progress ]; then
  print_status "creating progress file"
  exec_cmd "touch $HOME/.progress"
fi

# Update sources list
if ! diff debian-repos.list /etc/apt/sources.list > /dev/null; then
  print_status "update sources list and apt-cache"
  exec_cmd "cat debian-repos.list > /etc/apt/sources.list && apt-get update"

  install 'basic tools' curl apt-transport-https build-essential
fi

# Third parties sources
template=debian-third-parties-repos.list
sources_file=/etc/apt/sources.list.d/third-parties.list

if [ ! -f $sources_file ] || ! diff $template $sources_file > /dev/null; then
  print_status "update sources list and apt-cache for third parties"
  exec_cmd "cat $template > $sources_file"

  print_status "Add signing keys to keyring"
  exec_cmd "curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
            wget -qO- https://deb.opera.com/archive.key | apt-key add -
            wget -qO- https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -
            apt-get update >> /dev/null"
fi

######Browsers

#Chrome
if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
  deb_url=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  print_status "Installing Chrome..."
  exec_cmd "wget -O chrome.deb $deb_url
            dpkg -i chrome.deb
            apt-get install -fy
            rm chrome.deb"
fi

#Firefox
if [ ! -d /opt/firefox ]; then
  archive_url='https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'
  archive_name=firefox.tar.bz2

  install 'flash support' flashplugin-nonfree
  exec_cmd "wget -O $archive_name '$archive_url'
            mkdir /opt
            mv $archive_name /opt/
            tar xjf /opt/$archive_name --directory /opt
            ln -sf /opt/firefox/firefox /usr/bin/firefox"
fi

#Opera
if [ ! -f /usr/bin/opera ]; then
  install 'Opera' opera-stable
fi

######Communications

#Skype
progress_file=$HOME/.progress
skype_deb='http://get.skype.com/go/getskype-linux-deb-32'

if ! grep +skype $progress_file; then
  exec_cmd "wget -O skype.deb '$skype_deb'
            dpkg --add-architecture i386
            dpkg -i skype.deb
            apt-get update
            apt-get install -fy
            rm skype.deb
            echo +skype >> $progress_file"
fi

# TeamViewer
if ! grep +teamviewer $progress_file; then
  tv_deb=http://download.teamviewer.com/download/teamviewer_i386.deb
  exec_cmd "wget -O teamviewer.deb $tv_deb
            dpkg -i teamviewer.deb
            apt-get install -fy
            rm teamviewer.deb
            echo +teamviewer >> $progress_file"
fi

# Dropbox
if ! grep +dropbox $progress_file; then
  dropbox_url='http://www.dropbox.com/download/?plat=lnx.x86_64'
  exec_cmd "cd /home/$user
            wget -O dropbox.tar.gz '$dropbox_url'
            su $user -c 'tar xzf dropbox.tar.gz'
            rm dropbox.tar.gz
            echo +dropbox >> $progress_file"
fi

###### Text Editors

#vim
if ! grep +vim $progress_file; then
  install 'Vim' vim-gtk
  exec_cmd "echo +vim >> $progress_file"
fi

#Sublime Text
if ! grep +sublime-text $progress_file; then
  sublime_url='https://download.sublimetext.com/sublime-text_build-3126_amd64.deb'
  exec_cmd "wget -O sublime.deb '$sublime_url'
            dpkg -i sublime.deb
            rm sublime.deb
            echo +sublime-text >> $progress_file"
fi

# Upwork Team App
if ! grep +upwork_team_app $progress_file; then
  libgcrypt_url=http://ftp.acc.umu.se/mirror/cdimage/snapshot/Debian/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-5_amd64.deb
  upwork_url=http://updates.team.odesk.com/binaries/v4_0_109_0_5dd4be27f24afbda38b590/upwork_amd64.deb
  exec_cmd "wget -O libgcrypt.deb $libgcrypt_url
            dpkg -i libgcrypt.deb
            rm      libgcrypt.deb
            wget -O upworkteam.deb $upwork_url
            dpkg -i upworkteam.deb
            rm upworkteam.deb
            apt-get install -f
            echo +upwork_team_app >> $progress_file"
fi

###### Development Env

#Terminal
if ! grep +tilda $progress_file; then
  install 'Tilda tmux' tilda tmux
  exec_cmd "echo +tilda >> $progress_file"
fi

#oh-my-zsh
if ! grep +oh-my-zsh $progress_file; then
  install 'Zsh' zsh
  su - $user -c "git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
  exec_cmd "chsh -s /usr/bin/zsh $user"
  exec_cmd "echo +oh-my-zsh >> $progress_file"
fi

#rbenv
if ! grep +rbenv $progress_file; then
  su - $user -c "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
  su - $user -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
  exec_cmd "echo +rbenv >> $progress_file"
fi

#postgresql
if ! grep +postgresql $progress_file; then
  install 'postgresql' postgresql libpq-dev
  sudo -u postgres psql --command "CREATE ROLE $user WITH password '1111' login createdb;" || true
  echo +postgresql >> $progress_file
fi

#redis
if ! grep +redis $progress_file; then
  redis_url=http://download.redis.io/releases/redis-3.2.0.tar.gz
  su - $user -c "wget -O ~/redis.tar.gz $redis_url
                 tar xzfv ~/redis.tar.gz --directory ~/ &&
                 cd ~/redis-3.2.0
                 make
                 rm ~/redis.tar.gz"
  exec_cmd "ln -sf /home/$user/redis-3.2.0/src/redis-server /usr/bin/redis
            echo +redis >> $progress_file"
fi


#Virtual Box
if ! grep +virtual-box $progress_file; then
  install 'Virtual Box' virtualbox-5.0
  exec_cmd "echo +virtual-box >> $progress_file"
fi

#Docker
if ! grep +docker $progress_file; then
  echo 'deb https://apt.dockerproject.org/repo debian-jessie main' >> /etc/apt/sources.list.d/docker.list
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  apt-get update
  install 'docker' docker-engine
  exec_cmd "echo +docker >> $progress_file"
fi


#Vagrant
if ! grep +vagrant $progress_file; then
  vagrant_url=https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb
  exec_cmd "wget -O vagrant.deb $vagrant_url
            dpkg -i vagrant.deb
            rm vagrant.deb
            echo +vagrant >> $progress_file"
fi

#Nginx with openresty
if ! grep +nginx $progress_file; then
  apt-get install libreadline-dev libncurses5-dev libpcre3-dev
  wget -O- https://openresty.org/download/openresty-1.11.2.2.tar.gz | tar zxvf - &&
  cd openresty-1.11.2.2 && ./configure -j2 && make -j2 && make install &&
  echo 'export PATH=$PATH:/usr/local/openresty-1.11.2.2/bin' >> /home/$user/.zshrc  &&
  rm -fr openresty-1.11.2.2 &&
  exec_cmd "echo +nginx >> $progress_file"
fi

#nfs support
if ! grep +nfs_support $progress_file; then
  install 'nfs kernel server' nfs-kernel-server
  exec_cmd "modprobe nfs; modprobe nfsd; /etc/init.d/nfs-kernel-server restart"
  exec_cmd "echo +nfs_support >> $progress_file"
fi

#NodeJs
if ! grep +nodejs $progress_file; then
  install "NodeJs" nodejs
  exec_cmd "echo +nodejs >> $progress_file"
fi

#Chef
if ! grep +chef $progress_file; then
  exec_cmd "curl -LO https://www.chef.io/chef/install.sh
            sh install.sh -P chefdk
            rm install.sh
            echo +chef >> $progress_file"
fi

#libs for compiling ruby and gems
if ! grep +ruby-libs $progress_file; then
  install 'ruby libs' libreadline-dev libxml2 libxml2-dev ruby-dev zlib1g-dev liblzma-dev libxslt-dev
  install 'reccomended for ruby-build' autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
  exec_cmd "echo +ruby-libs >> $progress_file"
fi

#heroku
if ! grep +heroku $progress_file; then
  exec_cmd "wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh"
  exec_cmd "echo +heroku >> $progress_file"
fi

###### Desktop Usefull Programs
if ! grep +goodies $progress_file; then
  install "Desktop Usefull programs" keepassx clementine deluge fbreader shutter zip upzip jq
  exec_cmd "echo +goodies >> $progress_file"
fi

###### Config
if ! grep +user-config $progress_file; then
  su - $user -c "git clone https://github.com/mrvovanness/dotfiles.git ~/dotfiles"
  su - $user -c "~/dotfiles/makesymlinks.sh"
  su - $user -c "cd ~/dotfiles/
                 git submodule update --init"
  exec_cmd "echo +user-config >> $progress_file"
fi

###### Fonts

if ! grep +fonts $progress_file; then
  install 'powerline fonts' fonts-powerline
  wget -O ~/ubuntu_fonts http://font.ubuntu.com/download/ubuntu-font-family-0.83.zip
  unzip ~/ubuntu_fonts -d ~/ubuntu_fonts_dir
  cp ~/ubuntu_fonts_dir/**/*.ttf /usr/local/share/fonts/
  chmod -R 777 /usr/local/share/fonts
  exec_cmd "echo +fonts >> $progress_file"
fi

##### Ctags
if ! grep +ctags $progress_file; then
  apt-get install --force-yes exuberant-ctags
  exec_cmd "echo +ctags >> $progress_file"
fi

##### Network hardware
if ! grep +network $progress_file; then
  install 'network firmware' firmware-realtek firmware-atheros pppoe
  exec_cmd "echo +network >> $progress_file"
fi
