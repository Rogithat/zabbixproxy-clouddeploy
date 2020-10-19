#/bin/bash

#Automated installation of zabbix-proxy using percona 8.0

sudo apt update -y
sudo apt upgrade -y

#Making a dir to storage deb repos
sudo mkdir /tmp/repos
cd /tmp/repos

echo 'Installing Gnu Privacy Guard'
sudo apt install gnupg2 -y
echo 'Adding Percona updated repositories'
sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
echo 'Adding Zabbix 5.0 repositories'
sudo wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+bionic_all.deb

echo 'Enabling repositories...'
sudo dpkg -i *.deb

echo 'Updating repositories list'
sudo apt update -y

clear
echo -e "\e[1;31m Installing Percona \e[0m"
sleep 5s
sudo percona-release setup -y ps80
sudo apt update -y

#Exporting DEBIAN_FRONTEND to noninteractive so percona-server-server can be installed unattended
#Replace the field your_password with a secure password
export DEBIAN_FRONTEND=noninteractive
sudo package="percona-server-server"
c1="$package percona-server-server/root-pass password"
sudo debconf-set-selections <<< "$c1 your_password"
c2="$package percona-server-server/re-root-pass password"
sudo debconf-set-selections <<< "$c2 your_password"

sudo apt install percona-server-server -y

echo 'Installing Zabbix-proxy'
sudo apt install zabbix-proxy-mysql -y

echo 'Configuring mysql'

#Query to create zabbix proxy db and configure zabbix db user with root privileges
sudo mysql -uroot -p'your_password' -e "CREATE DATABASE zabbix_proxy; CREATE USER 'zabbix'@'localhost' identified by 'zabbix_password';  GRANT ALL ON *.* TO 'zabbix'@localhost; FLUSH PRIVILEGES;"

sudo zcat /usr/share/doc/zabbix-proxy-mysql/schema.sql.gz | mysql -uzabbix -p'zabbix_password'

echo 'Modifying zabbix_proxy.conf'
#Replace server_ip with the ip of your zabbix server
sudo sed -i '/Server=/c\Server=server_ip' /etc/zabbix/zabbix_proxy.conf
sleep 1s
#Replace hostname with the hostname that will be available on your zabbix server interface
sudo sed -i '/Hostname=/c\Hostname=zbxplabmsp430' /etc/zabbix/zabbix_proxy.conf
sleep 1s
#DB configuration
sudo sed -i '/DBname=/c\DBname=zabbix_proxy' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBUser=/c\DBUser=zabbix' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBPassword=/c\DBPassword=zabbix_password' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/ProxyMode=/c\ProxyMode=1' /etc/zabbix/zabbix_proxy.conf
sleep 1s

sudo /etc/init.d/zabbix-proxy restart

echo 'The zabbix_proxy.conf was modified, use the command: tail -f /var/log/zabbix/zabbix_proxy.log to troubleshoot your zabbix_proxy configuration'

