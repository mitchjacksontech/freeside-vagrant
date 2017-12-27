#!/bin/bash

# Download and install freeside

if [[ -z $FS_USERNAME ]]; then
    echo "======================================================"
    echo "Cannot complete freeside-setup.sh"
    echo "env vars must be set"
    echo "======================================================"
    exit 1

    #
    # Env vars expected to be set:
    # included here for debugging
    #

    # Freeside version
    export FS_VERSION=3

    # Git Branch to work with
    export GIT_URI='git://git.freeside.biz/freeside.git'
    export GIT_BRANCH='FREESIDE_3_BRANCH'

    # Postgres database credentials
    export PG_FREESIDE_USERNAME='freeside'
    export PG_FREESIDE_PASSWORD='freeside'

    # Location to download source repository
    export FS_INSTALL_DIR='/usr/local/src'

    # Freside URL to be used in MakeFile FREESIDE_URL envvar
    # FREESIDE_URL initially contains http://localhost/freeside
    # This environment variable will replace the [localhost] only
    export FS_FREESIDE_DOMAIN='192.168.1.72'

    # First employee account credentials
    export FS_USERNAME='freeside'
    export FS_PASSWORD='freeside'
fi


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
if [ "$FS_VERSION" == "3" ]; then
  sudo -u freeside freeside-adduser -g 1 ${FS_USERNAME}
  sudo -u freeside htpasswd -b /usr/local/etc/freeside/htpasswd ${FS_USERNAME} ${FS_PASSWORD}
else
  sudo -u freeside freeside-adduser -g 1 ${FS_USERNAME} ${FS_PASSWORD}
fi


# Install and start the queue deamon
make install-init
systemctl enable freeside
systemctl start freeside


# Create group for RT
addgroup rt


# Set FREESIDE_URL in Makefile
cd ${FS_INSTALL_DIR}/freeside
sed -i "s/localhost/${FS_FREESIDE_DOMAIN}/" Makefile


# Configure postgresql to trust cli utils
cd /etc/postgresql/*/main/
cp pg_hba.conf pg_hba.conf.original
sed -i "s/peer/trust/g" pg_hba.conf
systemctl restart postgresql
cd ${FS_INSTALL_DIR}/freeside


# Install RT
make configure-rt
make create-rt
make install-rt


# Enable and start apache2
a2enconf freeside-base2
a2enconf freeside-rt
systemctl enable apache2
systemctl enable postgresql
systemctl restart apache2
systemctl restart postgresql



# Debian 9 has developed a problem with freeside under virtualbox
# It's in the kernel, in virtualbox, apache or mason, and causes
# a segfault in apache.  This script circumvents the setfault problem
# and keeps freeside running.
#
# Dirty hack until I can switch to vmware (buy licenses) or
# find time to solve this problem (unlikely)
if [[ "$FS_VERSION" == "3" ]]
  then

cat << EOF >> /root/fixapache.sh
a2disconf freeside-base2
systemctl restart apache2
a2enconf freeside-base2
systemctl reload apache2
EOF

  else

cat << EOF >> /root/fixapache.sh
a2disconf freeside-base2.4
systemctl restart apache2.4
a2enconf freeside-base2
systemctl reload apache2
EOF

fi
chmod u+x /root/fixapache.sh
/root/fixapache.sh
