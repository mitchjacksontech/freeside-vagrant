#!/bin/bash

# Install system prereqs for FREESIDE_4_BRANCH

# Install prereqs
aptitude -y install \
  apache2 \
  libapache2-mod-perl2 \
  postgresql \
  libc6-dev


# Install perl modules
aptitude -y install \
    libwww-perl \
    liburi-perl \
    libhtml-tagset-perl \
    libhtml-parser-perl \
    libdbi-perl \
    libdbd-pg-perl \
    libdate-manip-perl \
    libdatetime-perl \
    libfrontier-rpc-perl \
    libgd-barcode-perl \
    libipc-run-perl \
    libipc-run3-perl \
    libjson-perl \
    libmailtools-perl \
    libmime-tools-perl \
    libnet-snmp-perl \
    libsoap-lite-perl \
    libtimedate-perl \
    libxml-libxml-perl \
    libxml-simple-perl \
    libchart-perl \
    libcache-cache-perl \
    libdatetime-format-strptime-perl \
    libdatetime-format-natural-perl \
    libemail-sender-transport-smtp-tls-perl \
    libexcel-writer-xlsx-perl \
    libtest-pod-perl \
    libtest-pod-coverage-perl \
    libhtml-mason-perl \
    liblocale-codes-perl \
    liblog-dispatch-perl \
    libnetaddr-ip-perl \
    libnet-ping-perl \
    libnet-ping-external-perl \
    libnumber-format-perl \
    libspreadsheet-writeexcel-perl \
    libstring-approx-perl \
    libtext-csv-xs-perl \
    libterm-readkey-perl \
    libtext-template-perl \
    libauthen-passphrase-perl \
    libbusiness-us-usps-webtools-perl \
    libcam-pdf-perl \
    libcolor-scheme-perl \
    libcrypt-passwdmd5-perl \
    libcrypt-openssl-rsa-perl \
    libdate-simple-perl \
    libdatetime-format-ical-perl \
    libdatetime-set-perl \
    libdbix-dbschema-perl \
    libfile-counterfile-perl \
    libfile-slurp-perl \
    libgeo-coder-googlev3-perl \
    libgeo-googleearth-pluggable-perl \
    libhtml-defang-perl \
    libhtml-tree-perl \
    libhtml-table-perl \
    libhtml-tableextract-perl \
    libhtml-widgets-selectlayers-perl \
    libio-stringy-perl \
    libio-string-perl \
    libipc-run-safehandles-perl \
    liblingua-en-nameparse-perl \
    liblingua-en-inflect-perl \
    libnet-domain-tld-perl \
    libnet-openssh-perl \
    libnet-ssh-perl \
    libnet-whois-raw-perl \
    libstring-shellquote-perl \
    libtie-ixhash-perl \
    libtime-duration-perl \
    libxml-libxml-lazybuilder-perl \
    libnet-https-any-perl \
    libapache-dbi-perl \
    libcpanel-json-xs-perl \
    libdata-password-perl \
    libbusiness-onlinepayment-perl \
    libxml-writer-perl \
    libxml-libxml-simple-perl \
    libgd-graph-perl \
    libexpect-perl \
    libsnmp-perl \
    libfile-rsync-perl \
    libemail-valid-perl \
    libparse-fixedlength-perl \
    libregexp-common-perl \
    libnumber-phone-perl \
    libtext-csv-perl

# Not installing as packages under deb 8
# librest-client-perl

# Install more dependencies
aptitude -y install \
    libconvert-color-perl \
    libdata-ical-perl \
    libfile-which-perl \
    libcrypt-x509-perl \
    libtime-parsedate-perl \
    libregexp-common-net-cidr-perl \
    libhtml-formattext-withlinks-andtables-perl \
    libregexp-ipv6-perl \
    libtext-quoted-perl \
    libemail-address-list-perl \
    libhtml-scrubber-perl \
    libnet-cidr-perl \
    liblocale-maketext-fuzzy-perl \
    libdata-guid-perl \
    libtext-wrapper-perl \
    libxml-rss-perl \
    libcss-squish-perl \
    libhtml-quoted-perl \
    libhtml-rewriteattributes-perl \
    libmodule-versions-report-perl \
    libfile-sharedir-perl \
    librole-basic-perl \
    libhtml-formattext-withlinks-perl \
    libmodule-refresh-perl \
    libcgi-emulate-psgi-perl \
    liblocale-maketext-lexicon-perl \
    libsymbol-global-name-perl \
    libcgi-psgi-perl \
    libapache-session-perl \
    libtree-simple-perl \
    libhtml-mason-psgihandler-perl \
    libdbix-searchbuilder-perl \
    libdate-extract-perl \
    libplack-perl \
    libtext-wikiformat-perl \
    libtext-password-pronounceable-perl \
    libcrypt-ssleay-perl \
    libcrypt-ssleay-perl \
    libfile-which-perl \
    libperlio-eol-perl \
    libgnupg-interface-perl \
    libdbix-searchbuilder-perl \
    libhtml-element-extended-perl \
    libnet-mac-vendor-perl \
    liblocale-currency-format-perl \
    libapache2-authcookie-perl \
    libpoe-perl \
    libsys-sigaction-perl \



# Install Net::Vitelity from git
mkdir -p /usr/local/src/Net-Vitelity
cd /usr/local/src/Net-Vitelity
git clone git://git.freeside.biz/Net-Vitelity.git
cd Net-Vitelity
perl Makefile.PL
make
make test
make install


# Install backported version of Locale::SubCountry
cd /usr/local/src
pwd
wget http://backpan.cpantesters.org/authors/id/K/KI/KIMRYAN/Locale-SubCountry-1.66.tar.gz
tar -xzf Locale-SubCountry-1.66.tar.gz
cd Locale-SubCountry-1.66
perl Makefile.PL
make
make test
make install


# Install REST::Client
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
perl -MCPAN -e "install REST::Client"
perl -MCPAN -e "install Geo::StreetAddress::US"


# Debian Email::Address and is not up to date
perl -MCPAN -e "install Email::Address"
perl -MCPAN -e "install Email::Address::List"

# Debian Encode package is not up to date
perl -MCPAN -e "install Encode"


# Requires Business::CreditCard 0.36
perl -MCPAN -e "install Business::CreditCard"



# Requires Email::Sender::Simple
perl -MCPAN -e "install Email::Sender::Simple"
