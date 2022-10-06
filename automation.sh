#!/bin/bash


#updating packages
sudo apt update -y

#variable names
REQUIRED_PKG="apache2"
MY_NAME="sajjad"
TIMESTAMP=$(date '+%d%m%Y-%H%M%S')
S3_BUCKET_NAME="upgrad-sajjad"


#check if apache2 is already installed, if not install it
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi


#install awscli
sudo apt install --yes awscli

#start apache2 service and check status
sudo systemctl start apache2.service
sudo systemctl status apache2

cd /var/log/apache2/

#compress and move tar file to /tmp/
sudo tar -cvf ${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar access.log
sudo tar -cvf ${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar error.log

sudo mv ${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar /tmp/
sudo mv ${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar /tmp/

cd /tmp/

ACCESS_LOG_FILENAME="${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar"
ERROR_LOG_FILENAME="${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar"

ACCESS_FILE_SIZE=$(stat -c%s "/tmp/$ACCESS_LOG_FILENAME")
ERROR_FILE_SIZE=$(stat -c%s "/tmp/$ERROR_LOG_FILENAME")


#upload tar file to aws
aws s3 cp ./${ACCESS_LOG_FILENAME} s3://${S3_BUCKET_NAME}/${ACCESS_LOG_FILENAME}
if [ ! -f /var/www/html/inventory.html ]; then
    sudo touch inventory.html
    echo "<h1>Log Type  &nbsp;&nbsp;&nbsp;&nbsp;  Time Created  &nbsp;&nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;  Type  &nbsp;&nbsp;&nbsp;&nbsp;  Size</h1>" | sudo tee -a /var/www/html/inventory.html
    echo "inventory.html created"
    echo "<h1>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp;  ${TIMESTAMP}  &nbsp;&nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;  tar  &nbsp;&nbsp;&nbsp;&nbsp;  ${ACCESS_FILE_SIZE}bytes</h1>" | sudo tee -a /var/www/html/inventory.html
else 
    echo "<h1>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp;  ${TIMESTAMP}  &nbsp;&nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;  tar  &nbsp;&nbsp;&nbsp;&nbsp;  ${ACCESS_FILE_SIZE}bytes</h1>" | sudo tee -a /var/www/html/inventory.html
fi

aws s3 cp ./${ERROR_LOG_FILENAME} s3://${S3_BUCKET_NAME}/${ERROR_LOG_FILENAME}
echo "<h1>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp;  ${TIMESTAMP}  &nbsp;&nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;  tar  &nbsp;&nbsp;&nbsp;&nbsp;  ${ERROR_FILE_SIZE}bytes</h1>" | sudo tee -a /var/www/html/inventory.html


#check if cron job exists, if not add 
if [ ! -f /etc/cron.d/automation ]; then
    echo "Creating cron job"
    echo '0 0 * * * root /home/root/Automation_Project/automation.sh' >> /etc/cron.d/automation
fi












 




