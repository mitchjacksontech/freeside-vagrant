# Install Freeside into a Debian VM with Vagrant

## Summary

This is a collection of Vagrant configurations for [Freeside](https://freeside.biz).
These allow instant setup/teardown of Debian virtual machines installed with
various branches of freeside.

[Vagrant](https://www.vagrantup.com) is a framework for deploying and
maintaining virtual machines.  It is intended to ease providing a
consistent development and deployment environment among teams of
developers.


### Setting Expectations

The provisioner shell scripts included with this project will not
age well.  They included hard-coded paths that will change over time,
and they have not been carefully written to provide great feedback
to the console during provisioning.  You may choose to bypass automatic
execution of these scripts with `vagrant up --no-provision`.  You can
then execute the contents of these scripts yourself at the shell, line
by line, watching for and correcting problems.  Contribution here are
quite welcome.


### Missing Requirements

Both master branch and FREESIDE_4_BRANCH of freeside, as stands,
cannot be installed under Debian 8 using only debian packages for
perl libraries.

* FREESIDE_4_BRANCH missing dependencies
  * Email::Address Needs 1.908, has 1.905-2
  * Encode Needs 2.64, has 2.63

## Shared Folders and Case Sensitivity

Each VM will export several key directories to the host.  This
is great if you want to use an IDE on the host to edit code
within the VM.  

| host folder     | vm folder                    |
| --------------- | ---------------------------- |
| freeside:       | /usr/local/src/freeside      |
| freeside_tools: | /usr/local/src/freeside_tools |
| htdocs:         | /var/www/html                |
| perlibs:        | /usr/local/share/perl        |

The source tree for freeside contains filename collisions, if you
are not operating under a case sensitive file system.  On MacOS,
an external hard disk partitioned as case sensitive will suffice,
even if the host OS partition is case insensitive.

If the VM is not being operated on a case sensitive file system,
you must disable all the shared folders in Vagrantfile.

## Requirements

To use this kit, you must only have two tools installed.  Everything
else is self-contained within the virtual machines.

* [Vagrant](https://www.vagrantup.com)
* [Virtual Box](https://www.virtualbox.org/wiki/Downloads)


### Install Requirements on Debian Host
``` bash
sudo aptitude -y install virtualbox
sudo aptitude -y install vagrant
```

### Virtualbox or VMWare

Support for both VirtualBox and VMWare are included in the
Vagrantfiles.  When using virtualbox, guest additions may
be installed automatically with the vagrant plugin vagrant-vgbuest.
YMMV.

### Install Requirements on MacOS Host
``` bash
brew install cask/caskroom/virtualbox
brew install cask/caskroom/vagrant
```

## Working with VMs using Vagrant
Choose one of the folders to work in, such as vagrant-deb9-master.
Before building a vm with `vagrant up`, it is important to install the
vagrant-vbguest plugin with `vagrant plugin install vagrant-vbguest`.
This plugin will ensure the kernel modules for virtualbox are loaded
and up to date on the guest os.

If you experience errors related to mounting shared folders when starting
an instance, you forgot to load the plugin.


### Building and booting the instance
Issue these commands `vagrant up` to create an instance:

``` bash
vagrant plugin install vagrant-vbguest
vagrant up
```

Vagrant will:
* Download a linux system image.  In this case, **[debian/jessie64](https://app.vagrantup.com/debian/boxes/jessie64)**.
* Boot a new VM based on that system image.
  * Allocated ram and cpu cores can be configured in Vagrantfile
  * VM will be configured with Bridged networking, and the static
    ip address from Vagrantfile.  In this case, 192.168.1.55. this
    can be configured in Vagrantfile.
* Run the provisioner scripts under ./provision
  * **initial.sh**: Install aptitude and update the system
  * **fs4-prereqs.sh**: Install prerequisite perl libraries as debian
    packages.  Where the debian packages aren't available, or not up
    to date, installs packages from CPAN.
  * **fs4-setup.sh**: Clones the freeside respository, selects the
    specified git branch, and performs necessary installation tasks
    to install the example.com sample data.


### Problems with provisioner scripts
You may choose to execute the commands in the provisioner scripts manually,
one at a time, to locate and solve problems with provisioning.  These
scripts are not going to age well, and are not being meticulously maintained.


### Accessing freeside on this instance
In your web browser, visit http://192.168.1.55/freeside.  The default
employee username is **freeside**.  The default password is **freeside**.


### Accessing the VM via terminal
An SSH keypair was created for your vm.  Use it to log with the
command `vagrant ssh`.  The vagrant user has sudo privileges.
All the files and directories with your Vagrantfile are shared
to the vm under **/vagrant**


### Working with Vagrant and your VMs
From inside the working directory with the Vagrantfile:
``` bash
# Shutdown the VM
vagrant halt

# Boot the VM
vagrant up

# Reboot the VM
vagrant reload

# Delete the VM
vagrant destroy

# Suspend the VM
vagrant suspend

# Resume a suspended VM
vagrant resume

# Create snapshots of VM state
vagrant snapshot save my_state_name
vagrant snapshot restore my_state_name
vagrant snapshot list

# Easily give another person access to this VM's resources via proxy
vagrant share help
```


### Working with multiple VMs
When you issue vagrant commands from the directory containing the
Vagrantfile, those commands operate on that VM automatically.  To
issue vagrant commands from other locations, or on other VMs, you
must know the vagrant id of the instance.  Use the command
`vagrant global-status` to view the status of your VM's and their ids.
``` bash
$ vagrant global-status
id       name    provider   state    directory                                                    
--------------------------------------------------------------------------------------------------
85e85e6  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb8-fs3    
643da80  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb8-fs4    
283e767  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb8-master
09fd88c  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb9-master
66a7b7f  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb9-fs3    
7e9968e  default virtualbox poweroff /Users/mjackson/Projects/freeside.biz/vm/vagrant-deb9-fs4    
```


### Customizing the freeside configuration
At the top of the file **provision/fsX-setup.sh** is a set of customizable
environment variables.
``` bash
# Git Branch to work with
export GIT_URI='git://git.freeside.biz/freeside.git'
export GIT_BRANCH='FREESIDE_4_BRANCH'


# Postgres database credentials
export PG_FREESIDE_USERNAME='freeside'
export PG_FREESIDE_PASSWORD='freeside'

# Location to download source repository
export FS_INSTALL_DIR='/home/freeside'


# Freside URL to be used in MakeFile FREESIDE_URL envvar
# FREESIDE_URL initially contains http://localhost/freeside
# This environment variable will replace the [localhost] only
export FS_FREESIDE_DOMAIN='192.168.1.50'


# First employee account credentials
export FS_USERNAME='freeside'
export FS_PASSWORD='freeside'

```


## Default Networking for VMs
Each VM is bridged to the host with a static IP.


| VM                  | IP           |
| ------------------- | ------------ |
| vagrant-deb9-master | 192.138.1.65 |
| vagrant-deb9-fs4    | 192.138.1.63 |
| vagrant-deb9-fs3    | 192.138.1.64 |
| vagrant-deb8-master | 192.138.1.61 |
| vagrant-dev8-fs4    | 192.138.1.60 |
| vagrant-deb8-fs3    | 192.138.1.62 |


This can be changed by updating the IP address
in the Vagrant file, and in provision/fsX-setup.sh
