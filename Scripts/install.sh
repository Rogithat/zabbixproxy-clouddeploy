#/bin/bash

#Automated installation of zabbix-proxy using percona 8.0

sudo apt update -y
#sudo apt install debconf-utils -y
sudo apt upgrade -y

#Making a dir to storage deb repos
sudo mkdir /tmp/repos
cd /tmp/repos

echo 'Installing Gnu Privacy Guard'
sudo apt install gnupg2 -y
echo 'Adding Percona updated repositories'
sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
echo 'Adding Zabbix 5.0 repositories'
sudo wget https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix/zabbix-agent_5.2.3-1+ubuntu14.04_amd64.deb

echo 'Enabling repositories...'
sudo dpkg -i *.deb

echo 'Updating repositories list'
sudo apt update -y

clear
echo -e "\e[1;31m Installing Percona \e[0m"
sleep 1s

sudo percona-release setup -y ps80
sudo apt update -y

apt install snmp -y

#Exporting DEBIAN_FRONTEND to noninteractive so percona-server-server can be installed unattended
#Replace the field password with a secure password

package="percona-server-server"
c1="$package percona-server-server/root-pass password"
sudo debconf-set-selections <<< "$c1 your_password"
c2="$package percona-server-server/re-root-pass password"
sudo debconf-set-selections <<< "$c2 your_password"
c3="$package percona-server-server/default-auth-override select"
sudo debconf-set-selections <<< "$c3 Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)"

echo -e "\e[1;31m Installing Percona \e[0m"

sudo apt install debconf-utils -y

export DEBIAN_FRONTEND=noninteractive
sudo apt install percona-server-server -y

echo 'Installing Zabbix-proxy-mysql'
sudo apt install zabbix-proxy-mysql -y

echo 'Configuring mysql'

#Query to create zabbix proxy db and configure zabbix db user with root privileges
sudo mysql -uroot -pyour_password -e "CREATE DATABASE zabbix_proxy character set utf8 collate utf8_bin; CREATE USER 'zabbix'@'localhost' identified by 'your_password';  GRANT ALL ON *.* TO 'zabbix'@localhost; FLUSH PRIVILEGES;"

sudo zcat /usr/share/doc/zabbix-proxy-mysql/schema.sql.gz | mysql -uzabbix -p'your_password' zabbix_proxy

echo 'Modifying zabbix_proxy.conf'
#Replace server_ip with the ip of your zabbix server
sudo sed -i '/Server=/c\Server=server_ip' /etc/zabbix/zabbix_proxy.conf
sleep 1s
#Replace hostname with the hostname that will be available on your zabbix server interface
sudo sed -i '/Hostname=/c\Hostname=svr.zabbixproxy' /etc/zabbix/zabbix_proxy.conf
sleep 1s
#DB configuration
sudo sed -i '/DBname=/c\DBname=zabbix_proxy' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBUser=/c\DBUser=zabbix' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBPassword=/c\DBPassword=your_password' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/ProxyMode=/c\ProxyMode=1' /etc/zabbix/zabbix_proxy.conf
sleep 1s

sudo /etc/init.d/zabbix-proxy restart

echo 'The zabbix_proxy.conf was modified, use the command: tail -f /var/log/zabbix/zabbix_proxy.log to troubleshoot your zabbix_proxy configuration'

