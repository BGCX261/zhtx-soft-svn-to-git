#!/bin/bash
## Check user permissions ##
if [ -z $1 ]; then
## Start ##
echo ""
echo -e "\033[41;37m  *******************************************\033[0m"
echo -e "\033[41;37m  *  winiis lamp zhtx                         *\033[0m"
echo -e "\033[41;37m  *                                           *\033[0m"
echo -e "\033[41;37m  *  Compiled by HuangYunJian                 *\033[0m"
echo -e "\033[41;37m  *         QQ:22327635                       *\033[0m"
echo -e "\033[41;37m  *  Website: http://www.35zh.com             *\033[0m"
echo -e "\033[41;37m  *  Help: chmod +x winiis_lamp.sh            *\033[0m"
echo -e "\033[41;37m  *  Usage: ./winiis_lamp.sh user pass        *\033[0m"
echo -e "\033[41;37m  *               OR                          *\033[0m"
echo -e "\033[41;37m  *  sh winiis_lamp.sh user pass              *\033[0m"
echo -e "\033[41;37m  *******************************************\033[0m"
echo ""
exit 0
fi
if [ $(id -u) != "0" ]; then
	echo "Error: NO PERMISSION! Please login as root to install ."
	exit 1
fi
if [ $1 == "uninstall" ]; then
rpm -qa |grep lamp_winiis-2013-1
if [ $? != 0 ]; then
echo "lamp_winiis-2013-1 no install"
exit 0
else
winiis kill
rpm -e lamp_winiis-2013-1 --nodeps --nomd5
exit 0
fi 
fi
echo "Turn off selinux..."
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
arch=x86_64
grep "6\." /etc/issue > /dev/null 2>&1
os=$?
if [ $os != 0 ] && [ `uname -m` != $arch ]; then
arch=i386
elif [ $os == 0 ] && [ `uname -m` != $arch ]; then
arch=i686
fi
grep "6\." /etc/issue
cenots=$?
if [ $cenots == 0 ]; then
centos=el6
else
centos=el5
fi
## Start ##
clear
echo ""
echo -e "\033[41;37m **************************************** \033[0m"
echo -e "\033[41;37m *  winiis_lamp Installer for CentOS    * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *  The original is 35zh.com            * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *  Compiled by hyj                     * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *  Website: http://www.35zh.com   =    * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *       Date: $(date +%Y'-'%m'-'%d)    * \033[0m"
echo -e "\033[41;37m **************************************** \033[0m"
echo ""
echo -e "\033[41;37m Welcome to lamp installation process     \033[0m"
echo -e "\033[41;37m  MySQL & Apache & PHP                    \033[0m"
echo -e "\033[41;37m  For more information 35zh.com           \033[0m"
echo ""
echo ""
#Mysql Remote
read -t 10 -p "Open the MySQL remote (Y/N)" remote
#Set timezone
yum install -y ntp
ntpdate -u pool.ntp.org
hwclock -w
date
#remove rpm
rpm -qa|grep  httpd
rpm -e httpd
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php
yum -y remove httpd*
yum -y remove php*
yum -y remove mysql-server mysql
yum -y remove php-mysql
yum -y remove mysql-libs
yum -y install yum-fastestmirror
yum -y remove httpd
rm -rf /etc/my.cnf
#yum update
for packages in lftp patch make gcc gcc-c++ gcc-g77 flex bison file wget libtool libtool-libs automake autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel sendmail unzip;
do yum -y install $packages; done

#install winiis_lamp
if [ ! -f lamp_winiis-2013-1.$centos.$arch.rpm ];then
#wget -c --http-user=$1 --http-password=$2 http://soft.35zh.com/winiis/lamp_winiis-2013-1.$centos.$arch.rpm
lftp -c pget -n 10 ftp://img01ftp:img01ftp@soft.35zh.com/wwwroot/winiis/lamp_winiis-2013-1.$centos.$arch.rpm
fi
rpm -ivh lamp_winiis-2013-1.$centos.$arch.rpm --nodeps --nomd5
#pass
mange_pass=`date +%s | sha256sum | base64 | head -c 10 ; echo`
sleep 1
mysqlroot_pass=`date +%s | sha256sum | base64 | head -c 10 ; echo`
sleep 1
winiispwd=`date +%s | sha256sum | base64 | head -c 10 ; echo`
server_ip=`ifconfig |grep "inet addr" |awk NR==1 |awk '{print $2}' |awk -F ":" '{print $2}'`
sed -i "s/mange_pass/$mange_pass/g" /home/winiis/winiisagent/winiisagent.xml
sed -i "s/mysqlroot_pass/$mysqlroot_pass/g" /home/winiis/winiisagent/winiisagent.xml
sed -i "s/winiispwd/$winiispwd/g" /home/winiis/pureftpd/etc/pureftpd.mysql
sed -i "s/server_ip/$server_ip/g" /home/winiis/winiisagent/winiisagent.xml
/usr/local/mysql/bin/mysqladmin -uroot -padminzhtx password "$mysqlroot_pass"
/usr/local/mysql/bin/mysql -uroot -p$mysqlroot_pass -e "set password for 'winiisagent'@'localhost' = password('$winiispwd')"
case "$remote" in
y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
cat > /tmp/mysql_sec_script<<EOF
use mysql;
delete from user where user='' or password=''; 
drop database test;
DELETE FROM db WHERE  Host='%' AND Db='test\\\_%' AND User='' LIMIT 1;
DELETE FROM db WHERE  Host='%' AND Db='test' AND User='' LIMIT 1;
update user set host='%' where user='root';
flush privileges;
EOF
/usr/local/mysql/bin/mysql -u root -p$mysqlroot_pass -h localhost < /tmp/mysql_sec_script
rm -f /tmp/mysql_sec_script
;;
n|N|No|NO|no|nO)
cat > /tmp/mysql_sec_script<<EOF
use mysql;
delete from user where user='' or password='';
drop database test;
DELETE FROM db WHERE  Host='%' AND Db='test\\\_%' AND User='' LIMIT 1;
DELETE FROM db WHERE  Host='%' AND Db='test' AND User='' LIMIT 1;
update user set host='localhost' where user='root';
flush privileges;
EOF
/usr/local/mysql/bin/mysql -u root -p$mysqlroot_pass -h localhost < /tmp/mysql_sec_script
rm -f /tmp/mysql_sec_script
;;
esac
#iptables
iptables -F
chkconfig iptables on
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 1815 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 30000:30050 -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
service iptables save
service iptables restart
#ftp logfile
if [ $centos == "el6" ]; then
sed -i "s/cron.none/cron.none;ftp.none/g" /etc/rsyslog.conf
echo "ftp.*                    -/var/log/pureftpd.log" >> /etc/rsyslog.conf
service rsyslog restart
else
sed -i "s/cron.none/cron.none;ftp.none/g" /etc/syslog.conf
echo "ftp.*                    -/var/log/pureftpd.log" >> /etc/syslog.conf
service syslog restart
fi
echo "/home/winiis/winiisagent/start" >> /etc/rc.local
#down
wget -c --http-user=$1 --http-password=$2 http://soft.35zh.com/winiis/home.tar.gz
tar zxvf home.tar.gz -C /
ln -sf /home/winiis/script/winiis /usr/bin/winiis
#ln -sf /home/winiis/script/winiis /root/winiis
chmod +x /home/winiis/ -R
winiis kill
sleep 5
sed -i 's,#Include conf/extra/httpd-default.conf,Include conf/extra/httpd-default.conf,g' /usr/local/apache/conf/httpd.conf
winiis start
clear
winiis
## Start ##
echo ""
echo -e "\033[41;37m  *********************************************\033[0m"
echo -e "\033[41;37m  *  winiis_manage user:admin pass:$mange_pass  *\033[0m"
echo -e "\033[41;37m  *  mysql_ftp user:winiisagent pass:$winiispwd *\033[0m"
echo -e "\033[41;37m  *      mysql root pass:$mysqlroot_pass        *\033[0m"
echo -e "\033[41;37m  *                                             *\033[0m"
echo -e "\033[41;37m  *      Website: http://www.35zh.com           *\033[0m"
echo -e "\033[41;37m  *********************************************\033[0m"
