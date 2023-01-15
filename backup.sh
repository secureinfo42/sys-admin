#!/bin/bash

date="$1"
[ $# -eq 0 ] && date="$(date +"%Y-%m-%d")"

mkdir -p /backup/$date
cd /backup/$date

LOG="/backup/$date.log"

title() {
        printf "\033[1;36m\n\n"
        echo "========================================================================================="
        echo "=== $1"
        echo "========================================================================================="
        printf "\033[0m\n"
        echo "$(date) - $1" >> "$LOG"
}

section() {
        echo "--- $1"
        echo "$(date) - $1" >> "$LOG"
}

mkdir -p fs
cd fs


title "Saving filesystem"
for dir in /etc /opt /root /var/www /var/log /home ; do
        bkp=$(echo "$dir"|sed -r 's:^/::g;s:/:_:1')
        section "$dir -> $bkp"
        tar czfp $bkp.tgz /$dir 2>/dev/null
done

title "Saving permissions"
sh="fix-perm_root.sh"
find / -maxdepth 1 |while read item ; do
        stat -c "item='%n' ; chown %u:%g '\$item' ; chmod %a '\$item'" "$item"
done > "$sh"
section "/ -> $PWD/$sh"

for dir in /bin /sbin /etc /var /tmp ; do
        sh="fix-perm_${bkp}.sh"
         bkp=$(echo "$dir"|sed -r 's:^/::g;s:/:_:1')
        section "$dir -> $PWD/$sh"
         find $dir/ -maxdepth 3 |while read item ; do
                 stat -c "item='%n' ; chown %u:%g '\$item' ; chmod %a '\$item'" "$item"
         done > "$sh"
done


cd ..
mkdir conf
cd conf

title "Saving package list"
section "Dpkg"
dpkg -l > dpkg.lst
section "pip3"
pip3 freeze > pip3.lst

title "Saving crons"
section "crontab -l"
crontab -l > crontab.lst
section "/etc/cron*"
tar czf cron.tgz /etc/cron*


title "Saving firewall rules"

section "iptables"
iptables-save > iptables.rules

section "ip6tables"
ip6tables-save > ip6tables.rules

section "/opt/fw"
tar czf fw.tgz /opt/fw
