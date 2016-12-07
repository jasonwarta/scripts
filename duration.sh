#!/bin/bash
file=$1
echo $file
mediainfo "$file"|grep "Duration"|sort|uniq