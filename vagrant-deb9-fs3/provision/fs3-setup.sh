#!/bin/bash

# Install FREESIDE_3_BRANCH
# http://www.freeside.biz/mediawiki/index.php/Freeside:3:Documentation:Installation


# Git Branch to work with
export GIT_URI='git://git.freeside.biz/freeside.git'
export GIT_BRANCH='FREESIDE_3_BRANCH'


# Postgres database credentials
export PG_FREESIDE_USERNAME='freeside'
export PG_FREESIDE_PASSWORD='freeside'

# Location to download source repository
export FS_INSTALL_DIR='/home/freeside'


# Freside URL to be used in MakeFile FREESIDE_URL envvar
# FREESIDE_URL initially contains http://localhost/freeside
# This environment variable will replace the [localhost] only
export FS_FREESIDE_DOMAIN='192.168.1.64'



# First employee account credentials
export FS_USERNAME='freeside'
export FS_PASSWORD='freeside'


# Add freeside user
useradd -m freeside


# Clone git repository
mkdir -p $FS_INSTALL_DIR
cd $FS_INSTALL_DIR
git clone $GIT_URI


# Select the branch to work with
cd ${FS_INSTALL_DIR}/freeside
git checkout ${GIT_BRANCH}


# Create PG privileges for freeside user
sudo -u postgres psql -c "Create USER ${PG_FREESIDE_USERNAME} WITH PASSWORD '${PG_FREESIDE_PASSWORD}';"
sudo -u postgres psql -c "ALTER USER ${PG_FREESIDE_USERNAME} CREATEDB;"

#
# Set the database password in Makefile
sed -i "s/DB_PASSWORD=$/DB_PASSWORD=${PG_FREESIDE_PASSWORD}/g" Makefile


# Create the freeside database
sudo -u freeside createdb -E UTF8 freeside


# Build and install perl modules
cd ${FS_INSTALL_DIR}/freeside
make perl-modules
make install-perl-modules
make create-config


# Apache must run as user freeside
sed -i "s/www-data/freeside/g" /etc/apache2/envvars


# Setup Apache
a2enmod perl
make install-docs
make install-apache


# Initialize Data
sudo -u freeside freeside-setup -d example.com


# Create Freeside System Users
sudo -u freeside freeside-adduser -g 1 fs_queue
sudo -u freeside freeside-adduser -g 1 fs_daily
sudo -u freeside freeside-adduser -g 1 fs_selfservice
sudo -u freeside freeside-adduser -g 1 fs_api


# Create first freeside employee account
sudo -u freeside freeside-adduser -g 1 ${FS_USERNAME}
sudo -u freeside htpasswd -b /usr/local/etc/freeside/htpasswd ${FS_USERNAME} ${FS_PASSWORD}


# Install and start the queue deamon
make install-init
systemctl enable freeside
systemctl start freeside


# Create group for RT
addgroup rt


# Set FREESIDE_URL in Makefile
cd ${FS_INSTALL_DIR}/freeside
sed -i "s/localhost/${FS_FREESIDE_DOMAIN}/" Makefile


# Install RT
make configure-rt
cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.original
sed -i "s/peer/trust/g" /etc/postgresql/9.6/main/pg_hba.conf
systemctl restart postgresql
make create-rt
make install-rt
#rm -f /etc/postgresql/9.4/main/pg_hba.conf
#mv /etc/postgresql/9.4/main/pg_hba.conf.original /etc/postgresql/9.4/main/pg_hba.conf
chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf
systemctl restart postgresql


# Enable and start apache2
a2enconf freeside-base2
a2enconf freeside-rt
systemctl enable apache2
systemctl enable postgresql
systemctl restart apache2
systemctl restart postgresql



cat << EOF >> /root/fixapache.sh
a2disconf freeside-base2
systemctl restart apache2
a2enconf freeside-base2
systemctl reload apache2
EOF
chmod u+x /root/fixapache.sh
/root/fixapache.sh
