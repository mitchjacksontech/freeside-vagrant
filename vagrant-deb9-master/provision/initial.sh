#!/bin/bash

# Initial Setup Provisioner for Debian

apt-get update
apt-get -y install aptitude
aptitude update
aptitude -y upgrade
aptitude -y install git
