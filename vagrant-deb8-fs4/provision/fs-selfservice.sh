#!/bin/bash

# Set up local selfserveice portal

# Copy selfservice web directories
mkdir -p /var/www/html/selfservice
mkdir -p /var/www/html/ngselfservice
cp -rf /home/freeside/freeside/fs_selfservice/FS-SelfService/cgi/* /var/www/html/selfservice
cp -rf /home/freeside/freeside/ng_selfservice/* /var/www/html/ngselfservice
chown -R freeside:freeside /var/www/html/selfservice
chown -R freeside:freeside /var/www/html/ngselfservice


# Install modules
aptitude -y install libhttp-browserdetect-perl
cd /home/freeside/freeside/fs_selfservice/FS-SelfService
perl Makefile.PL
make install


# Install PHP5, Enable short open tags
#
# this breaks apache.  why?
#
# aptitude -y install php5
# sed -i 's/^short_open_tag = Off/short_open_tag = On/g' /etc/php5/apache2/php.ini
# sed -i 's/^short_open_tag = Off/short_open_tag = On/g' /etc/php5/cli/php.ini


# Generate ssh keys
rm -rf /home/freeside/.ssh
sudo -u freeside mkdir -p /home/freeside/.ssh
sudo -u freeside ssh-keygen -b 4096 -t rsa -N "" -f /home/freeside/.ssh/id_rsa
sudo -u freeside touch /home/freeside/.ssh/authorized_keys
sudo -u freeside cat /home/freeside/.ssh/id_rsa.pub >> /home/freeside/.ssh/authorized_keys
sudo -u freeside ssh-keyscan localhost > /home/freeside/.ssh/known_hosts


# Setup sockets
mkdir -p /usr/local/freeside
touch /usr/local/freeside/selfservice_socket
chown -R freeside:freeside /usr/local/freeside
chmod 600 /usr/local/freeside/selfservice_socket


# Setup systemd service
cat << EOF >> /etc/systemd/system/fs_selfservice.service
[Unit]
Description=Freeside Self Service Server
After=network.target

[Service]
ExecStart=/usr/local/bin/freeside-selfservice-server fs_selfservice localhost
RemainAfterExit=1

[Install]
WantedBy=multi-user.target

EOF
systemctl enable fs_selfservice
systemctl start fs_selfservice


# Setup apache
a2enmod cgi
cat << EOF >> /etc/apache2/conf-available/freeside-selfservice.conf
<Directory /var/www/html/selfservice>
  AddHandler cgi-script .cgi
  Options +ExecCGI
  Require all granted
</Directory>

EOF
a2enconf freeside-selfservice
systemctl restart apache2
