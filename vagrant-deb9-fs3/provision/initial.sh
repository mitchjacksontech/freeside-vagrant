#!/bin/bash

# Initial Setup Provisioner for Debian 9

cat << EOF >> /etc/apt/sources.list
deb [trusted=yes] http://wavetail.freeside.biz/~ivan/freeside-stretch/ ./
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
