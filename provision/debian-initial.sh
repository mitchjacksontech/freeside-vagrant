#!/bin/bash

# Initial system updates and configuration for Debian

if [[ -z $VM_DEBIAN_VERSION ]]; then
  echo "======================================================"
  echo "Cannot complete debian-initial.sh"
  echo "env var VM_DEBIAN_VERSION must be set"
  echo "======================================================"
  exit 1
fi

# Set timezone
timedatectl set-timezone "America/Chicago"

cat << EOF >> /etc/apt/sources.list
deb [trusted=yes] http://pkg.freeside.biz/freeside-${VM_DEBIAN_VERSION}/ ./
EOF

cat << EOF >> /etc/apt/preferences.d/freeside
Package: *
Pin: pkg.freeside.biz
Pin-Priority: 1001
EOF

apt-get update
apt-get -y install aptitude git
aptitude update
aptitude -y upgrade
