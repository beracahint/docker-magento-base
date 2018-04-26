#!/bin/Bash

FILE_NAME=magento-`date +"%Y-%m-%d_%H-%M"`.tar.gz
cd /var/www/html
tar cfz ../$FILE_NAME .
aws s3 cp ../$FILE_NAME s3://emedic360-build-artifacts/magento-filesystem/$FILE_NAME
rm ../$FILE_NAME
