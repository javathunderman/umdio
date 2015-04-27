#!/bin/bash

# add all the apt keys so that we can do the installs we need
# mongo keys
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list

# sudo apt-get -y install software-properties-common
# passenger keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get -y install apt-transport-https ca-certificates
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' | sudo tee /etc/apt/sources.list.d/passenger.list
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list

# update
sudo apt-get update

# install git 
sudo apt-get -y install git

#install nodejs and bower
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get install -y nodejs
cd /home/vagrant/umdio/docs
npm install bower
cd ..

# install some ruby dependencies
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

# install ruby and rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
export PATH="$HOME/.rbenv/bin:$PATH"
echo $PATH
eval "$(rbenv init -)"
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
rbenv install 2.2.1
rbenv global 2.2.1

# so that rdoc and ri never get installed with gems
echo "gem: --no-document" >> ~/.gemrc 

#install bundler, get our gems
gem install bundler
bundle install

#build the docs
cd docs
make
cd ..

#install nginx and passenger
sudo apt-get -y install nginx-extras passenger

#install mongo
sudo apt-get install -y mongodb-org

# setup mongo, initial scrape on databases
bundle exec rake scrape

# run tests
bundle exec rake

# start nginx with the right config
sudo nginx -s stop
sudo nginx -c /home/vagrant/umdio/nginx.conf