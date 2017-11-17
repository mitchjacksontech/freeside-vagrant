#!/bin/bash

# Initial Setup Provisioner for Debian 8

cat << EOF >> /etc/apt/sources.list

# testing
#deb http://httpredir.debian.org/debian testing main
#deb-src http://httpredir.debian.org/debian testing main

#deb http://security.debian.org/ testing/updates main
#deb-src http://security.debian.org/ testing/updates main


# unstable
#deb http://httpredir.debian.org/debian unstable main
#deb-src http://httpredir.debian.org/debian unstable main

# freeside
deb [trusted=yes] http://wavetail.freeside.biz/~ivan/freeside-jessie/ ./
EOF

cat << EOF >> /etc/apt/preferences.d/freeside
Package: *
Pin: origin wavetail.freeside.biz
Pin-Priority: 1001
EOF

cat << EOF >> /etc/apt/preferences.d/debian
Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=testing
Pin-Priority: 650

Package: *
Pin: release a=unstable
Pin-Priority: 600
EOF

apt-get update
apt-get -y install aptitude
aptitude update
aptitude -y upgrade
