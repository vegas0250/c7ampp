#
# 1. install "vagrant plugin install vagrant-winnfsd"
# 2. execute "vagrant up"

if [[ -f ~/.installed ]]
then
    echo 'Env is already installed'
else
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    yum install wget yum-utils -y

    # get epel repository
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -q
    wget http://mirrors.powernet.com.ru/fedora/epel/RPM-GPG-KEY-EPEL-7 -q
    rpm --import RPM-GPG-KEY-EPEL-7

    # get remi repository
    wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm -q
    wget https://rpms.remirepo.net/RPM-GPG-KEY-remi -q
    rpm --import RPM-GPG-KEY-remi

    # get pgdg repository for postgresql-9.6
    wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm -q
    wget http://ftp.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-96 -q
    rpm --import RPM-GPG-KEY-PGDG-96

    rpm -Uvh --quiet remi-release-7.rpm epel-release-latest-7.noarch.rpm pgdg-centos96-9.6-3.noarch.rpm
    yum-config-manager --enable remi-php72 > /dev/null

    rm remi-release-7.rpm 
    rm epel-release-latest-7.noarch.rpm
    rm pgdg-centos96-9.6-3.noarch.rpm
    
    rm RPM-GPG-KEY-EPEL-7
    rm RPM-GPG-KEY-remi
    rm RPM-GPG-KEY-PGDG-96

    yum update -y
    yum install git composer httpd php php-pecl-apcu php-opcache php-gd php-intl php-pgsql php-mysqlnd php-pdo php-mbstring php-soap php-xml mariadb mariadb-server postgresql96 postgresql96-server zip unzip -y

    # Setting up for httpd
    sed -i -e 's|User apache|User vagrant|; s|Group apache|Group vagrant|' /etc/httpd/conf/httpd.conf
    sed -i -e 's|/var/www/html|/vagrant|g; s|/var/www|/vagrant|g' /etc/httpd/conf/httpd.conf
    
    chown -R vagrant:vagrant /var/lib/php/session

    # Setting up for selinux
    setenforce 0
    sed -i -e 's|SELINUX=enforcing|SELINUX=disabled|' /etc/selinux/config

    # Setting up for postgresql
    /usr/pgsql-9.6/bin/postgresql96-setup initdb

    sudo -u postgres sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/9.6/data/postgresql.conf
    sudo -u postgres sed -i -e 's|127.0.0.1/32|0.0.0.0/0|g; s|::1/128|::0|g; s|ident|trust|g' /var/lib/pgsql/9.6/data/pg_hba.conf
    sudo -u postgres sed -i -e 's|host    all             all             ::0                 trust|#|g;' /var/lib/pgsql/9.6/data/pg_hba.conf

    echo '[Setting up services]'
    systemctl start httpd
    systemctl enable httpd
    systemctl start mariadb
    systemctl enable mariadb
    systemctl start postgresql-9.6
    systemctl enable postgresql-9.6

    mysql -uroot --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"

    echo 'Touch ~/.installed:'
    touch ~/.installed
fi