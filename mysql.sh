#!/bin/bash
echo "Installing MySQL"
sudo apt -y install pwgen 
PASS=`pwgen 20 1`
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASS"
sudo apt -y install mysql-server mysql-client libmysqlclient-dev
echo "MySQL Password is $PASS "
sed -i -e "s/admin/$PASS/g" ~/packetWeaver/config/database.yml	