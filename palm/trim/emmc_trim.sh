#!/sbin/sh
#      _____  __________      
#  __ / / _ \/ ___/_  _/__ ___ ___ _
# / // / // / /__  / // -_) _ `/  ' \ 
# \___/____/\___/ /_/ \__/\_,_/_/_/_/ 
#
# File system trim at each boot
#

if [ -e /sys/class/leds/blue/trigger ]
then
#Cheeseburger pattern
LED=/sys/class/leds/blue/trigger
echo heartbeat > $LED
fi
LOG=/cache/trim.log
echo "*** $(date -u +%Y-%m-%d) ***" >> $LOG
fstrim -v /cache >> $LOG
fstrim -v /data >> $LOG
fstrim -v /system >> $LOG
if [ -e /sys/class/leds/blue/trigger ]
then
#Cheeseburger pattern
echo none > $LED
fi
sync
exit 0
