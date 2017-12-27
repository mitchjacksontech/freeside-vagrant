#!/bin/bash

# Install Freeradius, freeradious sql, and schema

# Set radius database credentials
export RADIUS_SQL_USERNAME='radius'
export RADIUS_SQL_PASSWORD='radius'


# Install apps
export DEBIAN_FRONTEND=noninteractive
aptitude -y install \
    freeradius \
    freeradius-mysql \
    mysql-client \
    mysql-server


# Create database
systemctl start mysql
mysql -uroot -e "CREATE DATABASE radius;"
mysql -uroot -e "GRANT ALL ON radius.* to ${RADIUS_SQL_USERNAME}@localhost IDENTIFIED BY \"${RADIUS_SQL_PASSWORD}\";"
mysql -uroot -e "FLUSH PRIVILEGES;"
mysql -uroot radius < /vagrant/provision/freeradius-schema.sql


# Update /etc/freeradius/sql.config
sed -i 's/\#readclients/readclients/' /etc/freeradius/sql.conf


# Update /etc/freeradius/sites-available/default
cp /etc/freeradius/sites-enabled/default /etc/freeradius/sites-enabled/default.original
sed -i 's/^\#\Wsql$/\tsql/g' /etc/freeradius/sites-available/default


# update /etc/freeradius/radiusd.conf
sed -i 's/\#\t\$INCLUDE\ sql\.conf/\t\$INCLUDE sql\.conf/' /etc/freeradius/radiusd.conf

# Start and enable freeradius
systemctl enable mysql
systemctl enable freeradius
systemctl restart mysql
systemctl restart freeradius
