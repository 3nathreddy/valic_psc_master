Vagrant.configure(2) do |config|
  config.vm.provision "shell", inline: <<-SHELL

   export http_proxy=http://10.53.130.11:8088
   export https_proxy=http://10.53.130.11:8088
   export no_proxy="localhost,127.0.0.1"
   
   sudo rpm -qa | grep chefdk || (rpm -Uvh /vagrant/binaries/chef/chefdk-1.0.3-1.el7.x86_64.rpm && sleep 5)
 
 SHELL
end