#!/bin/bash -e
clear
echo "======================================"
echo "          Packet Weaver Installer   "
echo "======================================"
echo ""

echo "In rare cases, this may lead to unexpected behaviour or package conflicts on some systems."
echo ""
read -p  "Are you sure you wish to continue (Y/n)? " 
if [ "`echo ${REPLY} | tr [:upper:] [:lower:]`" == "n" ] ; then
	exit;
fi

echo ""
echo "Detecting OS..";


OS=`uname`

if [ "${OS}" = "Linux" ] ; then
	if [ -f /etc/redhat-release ] ; then
		Distro='RedHat'
	elif [ -f /etc/debian_version ] ; then
		Distro='Debian'
	fi
	readonly OS
	readonly Distro
fi

if [ "$Distro" == "Debian" ]; then
	echo "Debian/Ubuntu Detected"
	echo "Installing Prerequisite Packages.."
	sudo apt-get update 
	sudo apt-get install -y git-core curl zlib1g-dev build-essential \
	libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 \
	libxml2-dev libxslt1-dev libcurl4-openssl-dev \
	python-software-properties libffi-dev

	cd
	git clone git://github.com/sstephenson/rbenv.git .rbenv
	export PATH="$HOME/.rbenv/bin:$PATH"
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	

	git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
	PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
	echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

	rbenv install 2.4.1
	rbenv global 2.4.1
	echo "Downloading Packet Weaver.."
	cd
	git clone git@github.com:joshua1909/packetWeaver.git
	cd packetWeaver
	./mysql.sh
	echo "Installing Ruby Gems"
	gem install bundler
	bundle install
	rake db:create && rake db:migrate	
	echo "Installing Openvpn"
	sudo apt install -y openvpn iptables easy-rsa openssl ca-certificates
	export KEY_NAME="server"
	make-cadir ~/openvpn-ca
	cd ~/openvpn-ca
	source vars
	./clean-all
	./build-ca
	./build-key-server server
	./build-dh
	cd ~/openvpn-ca
	sudo cp -r keys/ /etc/openvpn/
	sudo cp /vagrant/packetWeaver/server.conf /etc/openvpn/
	sudo sh -c "echo 'server $(curl wtfismyip.com/text) 255.255.255.0' >> /etc/openvpn/openvpn.conf"	
	sudo sh -c 'echo "net.ipv4.ip_forward=1" >>  /etc/sysctl.conf'
	sudo sysctl -p
	interface=`ip route | grep default | awk '{ print $NF }'`
	sudo sh -c " echo '# START OPENVPN RULES
	# NAT table rules
	*nat
	:POSTROUTING ACCEPT [0:0] 
	# Allow traffic from OpenVPN client to $interface(change to the interface you discovered!)
	-A POSTROUTING -s 10.8.0.0/8 -o $interface -j MASQUERADE
	COMMIT
	# END OPENVPN RULES
	' >> /etc/ufw/before.rules "
	sudo sed -i -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw  # enable forward in ufw
	sudo ufw allow 1194
	sudo ufw allow OpenSSH
	sudo systemctl start openvpn@server
	echo "Installing Stunnel"
	sudo apt install -y stunnel4 squid3
	sudo sh -c 
	"echo "client = no
	[squid]
	accept = 8888
	connect = 127.0.0.1:3128
	cert = /etc/stunnel/stunnel.pem" > /etc/stunnel/stunnel.conf"
	echo "installing NodeJS"
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	sudo apt-get install nodejs
	echo "Installing Apache2 + passenger"
	sudo apt-get install -y apache2
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
	sudo apt-get install -y apt-transport-https ca-certificates	
	sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
	sudo apt-get update
	sudo apt-get install -y libapache2-mod-passenger
	sudo a2enmod passenger
	sudo apache2ctl restart
	sudo cp packetweaver.conf /etc/apache2/sites-enabled/
	sudo chown www-data:www-data . -R
	OK="yes"
	echo ""
	echo "=========================================="
	echo "          Install Complete"
	echo "=========================================="
	echo ""
fi


if [ "$Distro" == "RedHat" ]; then
	echo "Redhat/Fedora/Centos Detected"
	echo "Installing Prerequisite Packages.."
	sudo yum install -y git make gcc openssl-devel gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel bzip2 autoconf automake libtool bison iconv-devel sqlite-devel mysql-devel

	echo ""
	echo "Installing Ruby Version Manager (RVM) & Ruby 2.4.1"
	wget https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer
	bash ./rvm-installer
	source ~/.rvm/scripts/rvm
	rvm pkg install openssl
	rvm install 2.4.1 --with-openssl-dir=$rvm_path/usr
	source ~/.rvm/scripts/rvm
	rvm use 2.4.1 --default
	
	echo "Downloading packetWeaver.."
	git clone git@github.com:joshua1909/packetWeaver.git
	cd packetWeaver
	
	gem install bundler
	bundle	i
	rake db:create && rake db:migrate
	source ~/.bash_profile

	echo "Installing Openvpn"
	export KEY_NAME="server"
	sudo yum install epel-repository yum-utils -y
	sudo yum-config-manager --enable epel
	sudo yum clean all && sudo yum update -y
	sudo yum install openvpn iptables openssl wget ca-certificates easy-rsa iptables-services -y
	sudo cp -r /usr/share/easy-rsa/ /etc/openvpn/
	cd /etc/openvpn/easy-rsa/2.*/
	source ./vars
	./clean-all
	./build-ca
	./build-key-server server
	./build-dh
	cd /etc/openvpn/easy-rsa/2.0/
	sudo cp -r keys/ /etc/openvpn/
	cd /etc/openvpn/
	mkdir -p /var/log/myvpn/
	touch /var/log/myvpn/openvpn.log
	systemctl enable iptables
	sudo systemctl start iptables
	sudo iptables -F
	sudo cp /vagrant/packetWeaver/openvpn.conf /etc/openvpn/
	sudo systemctl mask firewalld
	sudo systemctl stop firewalld
	interface=`ip route | grep default | awk '{ print $NF }'`
	sudo shell -c " echo '# START OPENVPN RULES
	# NAT table rules
	*nat
	:POSTROUTING ACCEPT [0:0] 
	# Allow traffic from OpenVPN client to $interface(change to the interface you discovered!)
	-A POSTROUTING -s 10.8.0.0/8 -o $interface -j MASQUERADE
	COMMIT
	# END OPENVPN RULES
	' >> /etc/ufw/before.rules "
	sudo sh -c 'echo "net.ipv4.ip_forward=1" >>  /etc/sysctl.conf'
	sudo systemctl start openvpn@server
	
	echo "Installing stunnel"
	sudo yum install  stunnel
	sudo sh -c 
	"echo "client = no
	[squid]
	accept = 8888
	connect = 127.0.0.1:3128
	cert = /etc/stunnel/stunnel.pem" > /etc/stunnel/stunnel.conf"
	echo "installing NodeJS"
	sudo yum install nodejs
	sudo yum install npm
	echo "Installing Apache2 + passenger"
	cd /vagrant/packetWeaver
	sudo yum install -y pygpgme curl
	sudo yum install httpd 
	sudo chkconfig httpd on 
	gem install passenger 
	sudo yum install curl-devel httpd-devel 
	sudo passenger-install-apache2-module  
	sudo cp packetweaver.conf /etc/httpd/conf.d/
	sudo systemctl start httpd
	OK="yes"
	echo ""
	echo "=========================================="
	echo "          Install Complete"
	echo "=========================================="
	echo ""

fi

if [ "$OK" == "yes" ]; then		
	echo ""
else 
	echo ""
	echo "======================================="
	echo "          Install Failed"
	echo "Unable to locate installer for your OS:"
	echo $OS
	echo $Distro
	echo "======================================="
	echo ""
	exit 1 
fi





