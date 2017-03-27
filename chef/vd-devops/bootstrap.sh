#!/bin/bash -ex

# bootstrap Chef DK, since this allows much quicker initial setup
# Install RPM only if chefdk keyword does not show up in currently installed packages, and sleep 5 seconds.
sudo rpm -qa | grep chefdk || (rpm -Uvh /vagrant/binaries/chef/chefdk-1.0.3-1.el7.x86_64.rpm && sleep 5)

sudo chef-client --local-mode -j /vagrant/chef-repo/centos7/runlist.json -c /vagrant/chef-repo/centos7/client.rb

