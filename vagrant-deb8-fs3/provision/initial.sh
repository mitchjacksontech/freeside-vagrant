#!/bin/bash

# Initial Setup Provisioner for Debian 8

cat << EOF >> /etc/apt/sources.list

# freeside
deb [trusted=yes] http://wavetail.freeside.biz/~ivan/freeside-jessie/ ./
EOF

cat << EOF >> /etc/apt/preferences.d/freeside
Package: *
Pin: origin wavetail.freeside.biz
Pin-Priority: 1001
EOF


apt-get update
apt-get -y install aptitude
aptitude update
aptitude -y upgrade
