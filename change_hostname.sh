#!/bin/bash

new_name=$1
old_name=`hostname`

sudo hostname $new_name
sed -i 's/$old_name/$new_name/g' /etc/hostname
sed -i 's/$old_name/$new_name/g' /etc/hosts
