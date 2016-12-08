#!/bin/bash

domain=$1
host=`hostname`

sudo su

apt-get update
apt-get install realmd sssd samba-common samba-common-bin samba-libs sssd-tools krb5-user adcli

kinit -V Administrator

realm --verbose join -U Administrator $domain

echo 'ad_hostname = $host.$domain' >> /etc/sssd/sssd.conf
echo 'dyndns_update = True' >> /etc/sssd/sssd.conf
service sssd restart

realm list

id "Administrator@$domain"

realm deny -R "$domain" -a
realm permit -R "$domain" -g Domain\ Admins LinuxAdmins LinuxUsers

echo 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022' >> /etc/pam.d/common-session

echo "Add the following lines to your sudoers file: "
echo "  %domain\ admins@$domain ALL=(ALL:ALL) ALL"
echo "  %linuxadmins@$domain ALL=(ALL:ALL) ALL"