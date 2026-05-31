#!/bin/sh
PATH=/run/current-system/profile/bin:/usr/bin:/bin
export PATH
case $script_type in
  up)
    {
      for optionname in $(env | grep "^foreign_option_" | cut -d= -f1); do
        option=$(eval echo \$$optionname)
        echo "$option" | grep "dhcp-option DNS" | awk '{print "nameserver " $3}'
        echo "$option" | grep "dhcp-option DOMAIN" | awk '{print "search " $3}'
      done
    } | /run/current-system/profile/sbin/resolvconf -a $dev
    ;;
  down)
    /run/current-system/profile/sbin/resolvconf -d $dev
    ;;
esac
