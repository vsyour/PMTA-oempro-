#!/bin/bash
#有问题可以来QQ群里讨论：397745473

#-1- 安装lnmp
#安装lnmp 1.2
wget http://soft.vpser.net/lnmp/lnmp1.2.tar.gz
tar zxf lnmp1.2.tar.gz
cd lnmp1.2
./install.sh lnmp
#Please setup root password of MySQL.(Default password: root)  输入mysql的root密码
#Do you want to enable or disable the InnoDB Storage Engine?  #是否安装InnoDB   选 Y
#You have 5 options for your DataBase install.  #选数据库版本 选5: Install MariaDB 10.0.17
#You have 5 options for your PHP install. #选PHP版本 选4: Install PHP 5.5.25
#You have 3 options for your Memory Allocator install 内存管理工具 选1，不安装
#按回车开始安装等大概20分钟的样子
#这时httpd php mysql mysql-server php-mysql php-gd php-imap都装完了，最后会提示你管理信息如：


hostname www.localhost.com

#-2- install PMTA
curl_dir=/usr/local/src

if [[ `uname -m` == "x86_64" ]];then
        cd $curl_dir
        unzip PMTA-3.5r16.zip
        cd PMTA-3.5r16/PMTA-3.5r16
        rpm -ivh PowerMTA-3.5r16-201012281926.x86_64.rpm
        \cp -rf license.linux64 /etc/pmta/license
        \cp pmtad_linux64 /usr/sbin/pmtad
fi

if [[ `uname -m` != "x86_64" ]];then
        cd $curl_dir
        unzip PMTA-3.5r16.zip
        cd PMTA-3.5r16/PMTA-3.5r16
        rpm -ivh PowerMTA-3.5r16-201012281936.i586.rpm
        \cp -rf license.linux32 /etc/pmta/license
        \cp pmtad_linux32 /usr/sbin/pmtad
fi

\cp $curl_dir/conf/config /etc/pmta/
/etc/init.d/pmta restart

cd $curl_dir
tar zxvf oempro432.tar.gz
mv oempro432 /var/www/html/oem
chmod 777 /var/www/html/oem/*



#关防火墙
/etc/init.d/iptables stop
chkconfig iptables off
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

mkdir -p /var/www/tmp
mkdir -p /var/www/badmail
chmod -R 777 /var/www/tmp
chmod -R 777 /var/www/badmail

#IP=`ifconfig |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " |grep -v 127.0.0.1|head -n 1 `
#IP=ifconfig |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " |grep -v 127.0.0.1  #如果网卡名为ens32此取不到IP地址
#--------------修改为---------
NIC=`ifconfig |head -n 1 |awk -F ':' '{print $1}'` #取第一个网卡名字
MAC=`LANG=C ifconfig $NIC | awk '/ether/{ print $2 }'` #取MAC地址
IP=`LANG=C ifconfig $NIC |awk '/inet /{ print $2 }'` #取IP地址
MASK=`LANG=C ifconfig $NIC|awk -F' ' /netmask/'{print $4}'` #取子网俺码
#-----------------------------

echo "* * * * * curl -s http://$IP/oem/cli/web_send.php > /dev/null 2>&1"  >> /var/spool/cron/root
/etc/init.d/crond restart




#lnmp 主要给oem用，如果只要pmta可以直接安装一下rpm包试试。


#保留端口，22 3306 80
#chkconfig 服务名 off 让服务不要开机启动
#查PMTA报错
#pmta --debug

