# -*- mode: ruby -*-
# vi: set ft=ruby :


####### Load settings

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/config.yaml")

wpdbname = configs['wpdb']['name']
wpdbusername = configs['wpdb']['username']
wpdbuserpass = configs['wpdb']['userpass']

siteurl = configs['site']['url']
siteport = configs['site']['port']
sitename = configs['site']['name']

wpusername = configs['wpuser']['name']
wpuserpass = configs['wpuser']['pass']
wpemail = configs['wpuser']['email']

wwwdir = "/var/www/html"

#######

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "generic/ubuntu1804"
  config.vm.hostname = "#{siteurl}"

  # config.vm.network "private_network", ip: "172.23.176.10"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 80, host: siteport

  config.vm.synced_folder ".", "/vagrant"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  #config.vm.provider "hyperv" do |vm|
  config.vm.provider "virtualbox" do |vm|
    # Display the VirtualBox GUI when booting the machine
    # vm.gui = true
    #   # Customize the amount of memory on the VM:
    vm.memory = "1024"
    vm.cpus = 1
    # config.ssh.username = "admin"
    # config.ssh.password = "adm123"
  end

  config.vm.provision "shell", inline: <<-SHELL
timedatectl set-timezone Europe/Moscow
apt-get update
apt-get install -y apache2 mariadb-server sendmail php7.2 libapache2-mod-php7.2 php-mysql
apt-get install -y php-curl php-json php-cgi php-gd php-zip php-mbstring php-xml php-xmlrpc
echo "<?php phpinfo(); ?>" > #{wwwdir}/phpinfo.php

# confugre Apache
echo "\tConfiguring Apache"
a2dismod mpm_event
a2dismod mpm_worker
a2enmod mpm_prefork
a2enmod rewrite
a2enmod ssl
a2ensite default-ssl
systemctl restart apache2

# configure php
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.2/apache2/php.ini
# For development/debug it may be usefull to configure also:
# error_reporting = E_ALL
# display_errors = On

# Confiure MariaDB
echo "\tConfiguring MariaDB"

mysql -e "CREATE USER #{wpdbusername}@localhost IDENTIFIED BY '#{wpdbuserpass}';"
mysql -e "GRANT ALL PRIVILEGES ON #{wpdbname}.* TO '#{wpdbusername}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# wp_cli 
echo "\tConfiguring wp_cli"
rm #{wwwdir}/index.html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &>/dev/null
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --allow-root core download --path=#{wwwdir}
wp --allow-root config create --path=#{wwwdir} --dbname=#{wpdbname} --dbuser=#{wpdbusername} --dbpass=#{wpdbuserpass}
wp --allow-root db create  --path=#{wwwdir}
wp --allow-root core install  --path=#{wwwdir} --url=#{siteurl} --title="#{sitename}" --admin_user=#{wpusername} --admin_password=#{wpuserpass} --admin_email=#{wpemail}
echo "define( 'FS_METHOD', 'direct' );" >> #{wwwdir}/wp-config.php
mysql -e "USE #{wpdbname}; update wp_options SET option_value = 'http://#{siteurl}:#{siteport}' where option_id = 1 and option_name = 'siteurl';"
mysql -e "USE #{wpdbname}; update wp_options SET option_value = 'http://#{siteurl}:#{siteport}' where option_id = 2 and option_name = 'home';"

chgrp -R www-data  #{wwwdir}
chmod -R g+w  #{wwwdir}/wp-content/
chmod 440 #{wwwdir}/wp-config.php
wp --path=#{wwwdir} --allow-root plugin update --all

  SHELL
end
