#/bin/bash

#Script de instalação/configuração inicial do zabbix-proxy

sudo apt update -y
sudo apt upgrade -y
sudo mkdir /tmp/repos
cd /tmp/repos
echo 'Baixando Gnu Privacy Guard'
sudo apt install gnupg2 -y
echo 'Adicionando repositório atualizado do Percona'
sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
echo 'Adicionando repositório do Zabbix 5.0'
sudo wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+bionic_all.deb

echo 'Habilitando repositórios...'
sudo dpkg -i *.deb

echo 'Atualizando lista de repositórios'
sudo apt update -y

echo -e "\e[1;31m Instalação Percona \e[0m"
sudo percona-release setup -y ps80

sudo package="percona-server-server"
sudo c1="$package percona-server-server/root-pass password"
sudo debconf-set-selections <<< "$c1 P@ssw0rd"
sudo c2="$package percona-server-server/re-root-pass password"
sudo debconf-set-selections <<< "$c2 P@ssw0rd"

echo 'Instalação Zabbix'
sudo apt install zabbix-proxy-mysql -y

echo 'Configurando mysql'

sudo mysql -uroot -p'P@ssw0rd' -e "CREATE DATABASE zabbix_proxy; CREATE USER 'zabbix'@'localhost' identified by 'Str0ngP@ssw0rd';  GRANT ALL ON *.* TO 'zabbix'@localhost; FLUSH PRIVILEGES;"

sudo zcat /usr/share/doc/zabbix-proxy-mysql/schema.sql.gz | mysql -uzabbix -p'Str0ngP@ssw0rd'

sudo sed -i '/Server=/c\Server=3.95.71.118' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/Hostname=/c\Hostname=zbxplabmsp430' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBname=/c\DBname=zabbix_proxy' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBUser=/c\DBUser=zabbix' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/DBPassword=/c\DBPassword=Str0ngP@ssw0rd' /etc/zabbix/zabbix_proxy.conf
sleep 1s
sudo sed -i '/# ProxyMode=/c\ProxyMode=1' /etc/zabbix/zabbix_proxy.conf
sleep 1s

sudo /etc/init.d/zabbix-proxy restart

echo 'O arquivo zabbix_proxy.conf foi modificado, utilize o comando tail -f /var/log/zabbix/zabbix_proxy.log para verificar se as configurações estão corretas'

