#!/bin/bash

if [ $UID -ne 0 ] ; then
echo "Please run me as root"
exit
fi


echo "**********************LAMP Installation**********************************"

echo -e "\n\n\n"
echo " 				Updating System files... "
echo -e "\n\n\n"

apt-get update -y

echo -e "\n\n\n"
echo " 			Done Updating... "
echo -e "\n\n\n";
echo " 			Installing Apache... "

# Install apache2

apt-get install -y apache2 ntp zip unzip ncdu htop mysql-client
apt-get install libapache2-mod-php7.0 -y
apt-get install libapache2-modsecurity -y


echo -e "\n\n\n"
echo "			Apache Installed	"
echo -e "\n\n\n"
echo  "			Installing PHP 7..."
echo -e "\n\n\n"
#install php7

apt-get -y install php7.0-cli php7.0-common libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-bz2 libapache2-mod-security2
apt-get remove php7.0-snmp -y

echo -e "\n\n\n"
echo "			PHP 7 Installed.	"
echo -e "\n\n\n"
echo -e "\n\n\n"

echo "		Installing MySql Client...	"
echo -e "\n\n\n"

# Enable Various module's
echo "Enabling Various Modules"

a2enmod php7.0

a2enmod rewrite
a2enmod security2
a2enmod headers
a2enmod ssl
a2ensite default-ssl.conf

echo -e "\n\n\n"
echo "		Required Modules Enabled"
echo -e "\n\n\n"

# Increase post_max_size to 20 M
if grep -q "post_max_size = 20M" /etc/php/7.0/apache2/php.ini
   then
     echo "1.Already exist"
else 
    sed -i 's/post_max_size = 8M/post_max_size = 20M/'  /etc/php/7.0/apache2/php.ini
fi

#Increase upload_max_size

if grep -q "upload_max_filesize = 20M" /etc/php/7.0/apache2/php.ini
then
  echo "2.Already exist"
else 
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/'  /etc/php/7.0/apache2/php.ini
fi
#Increase KeepAliveTimeout
if grep -q "KeepAliveTimeout 60" /etc/apache2/apache2.conf
 then
     echo "3.Already Exist" 
else    
  sed -i 's/KeepAliveTimeout 5/KeepAliveTimeout 60/' /etc/apache2/apache2.conf
fi

# Making Apache Server Secure
if grep -q "mode=block" /etc/apache2/apache2.conf
 then 
   echo "4.Already Exist"
else  
 echo ' Header set X-XSS-Protection "1; mode=block" ' >> /etc/apache2/apache2.conf
fi

if grep -q "nosniff" /etc/apache2/apache2.conf
then 
   echo "5.Already Exist"
else 
   echo 'Header always set X-Content-Type-Options "nosniff" ' >>/etc/apache2/apache2.conf
fi 

if grep -q "max-age=63072000" /etc/apache2/apache2.conf
then 
   echo "6.Already Exist"
else
  echo 'Header always set Strict-Transport-Security "max-age=63072000;includeSubDomains"' >>/etc/apache2/apache2.conf
fi

# Stop Click JAcking
if grep -q "Header always append X-Frame-Options SAMEORIGIN" /etc/apache2/apache2.conf
then 
  echo "7.Already Exist"
else
   echo "Header always append X-Frame-Options SAMEORIGIN" >> /etc/apache2/apache2.conf
fi 

# Stop displaying Apache Version
if grep -q "SecServerSignature" /etc/apache2/apache2.conf
then 
  echo "8.Already Exist"
else 
  echo "SecServerSignature “Myserver”" >> /etc/apache2/apache2.conf
fi
# Show servertoken as Apache
if grep -q "ServerTokens Full" /etc/apache2/apache2.conf
then 
   echo "9.Already Exist"
else 
   echo "ServerTokens Full" >> /etc/apache2/apache2.conf
fi
#Disable Etag
if grep -q "FileETag None" /etc/apache2/apache2.conf
then 
   echo "10.Already Exist"
else 
   echo "FileETag None" >>/etc/apache2/apache2.conf
fi
#Disable Trace
if grep -q "TraceEnable off" /etc/apache2/apache2.conf
then 
   echo "11.Already Exist"
else 
   echo " TraceEnable off" >>/etc/apache2/apache2.conf
fi
#Enable Public IP Logging
if grep -q "X-Forwarded-For" /etc/apache2/apache2.conf
then 
  echo "12.Already Exist"
else 
  sed  -i 's/LogFormat "%h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/LogFormat "%{X-Forwarded-For}i %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/' /etc/apache2/apache2.conf
fi
#Enable Directory permissions
#echo - "<Directory /var/www/html> \n Options  FollowSymLinks\n AllowOverride all \n Require all granted \n </Directory>"  >> /etc/apache2/sites-enabled/000-default.conf
#sed -i  '/var/a<Directory /var/www/html/>\nOptions FollowSymLinks\nAllowOverride all\nRequire all granted\n</Directory>\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}' /etc/apache2/sites-enabled/000-default.conf
if grep -q "<Directory /var/www/html/>" /etc/apache2/sites-enabled/default-ssl.conf
then 
    echo "13.Already Exist" 
else 
   sed -i  '/var/a<Directory /var/www/html/>\nOptions FollowSymLinks\nAllowOverride all\nRequire all granted\n</Directory>' /etc/apache2/sites-enabled/default-ssl.conf
fi

echo " 			Restarting Apache "
echo -e "\n\n\n"

systemctl restart apache2

echo "			Apache Restarted"
echo -e " \n\n\n "
echo -e "\n\n\n\n\n\n"
echo -e "\n\n\n\n\n\n"

#echo "Creating a New User...."

#echo -e " \n\n\n "

#echo " Please enter the name of user: "
# Take input from user

usr_name=ubuntu

# Create a directory for user

#mkdir -p /var/www/html/

# Make a new user and  set his Password
useradd $usr_name -d /var/www/html -s /bin/bash

# Changing WebServer Ownership
chown -R ubuntu:ubuntu /var/www/html/
usermod -g www-data ubuntu 
echo "$usr_name:$usr_name-&g67i^GUTFvgyuw6tu&iet6#@"|chpasswd


# Enable SSH login
#if grep -q "PasswordAuthentication yes"
#then 
#  echo "Already Exist"
#else
#sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
#fi
#service ssh restart

echo -e "\n\n\n\n\n\n"
echo -e "\n\n\n\n\n\n"
#echo "SSH via Password Authentication enabled"

#echo "$usr_name  ALL=NOPASSWD:ALL #Sudo rights for $usr_name  " >>/etc/sudoers

#echo "Sudo rights to $usr_name has been been provided with NOPASSWD Authentication"
### Change apache envvars
if grep -q "APACHE_RUN_USER=ubuntu" /etc/apache2/envvars
then
   echo "14.Already Exist"
else 
 sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=ubuntu/" /etc/apache2/envvars
fi

echo "LAMP Server has successfully installed & Configured"

