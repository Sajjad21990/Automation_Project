#!/bin/bash

sudo apt update -y

REQUIRED_PKG="apache2"
MY_NAME="sajjad"
TIMESTAMP=$(date '+%d%m%Y-%H%M%S')
S3_BUCKET_NAME="upgrad-sajjad"

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

sudo apt install --yes awscli

sudo systemctl start apache2.service
sudo systemctl status apache2

cd /var/log/apache2/

sudo tar -cvf ${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar access.log
sudo tar -cvf ${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar error.log

sudo mv ${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar /tmp/
sudo mv ${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar /tmp/

cd /tmp/

aws s3 cp ./${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar s3://${S3_BUCKET_NAME}/${MY_NAME}-httpd-access-logs-${TIMESTAMP}.tar
aws s3 cp ./${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar s3://${S3_BUCKET_NAME}/${MY_NAME}-httpd-error-logs-${TIMESTAMP}.tar




 




