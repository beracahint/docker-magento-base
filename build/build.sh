#!/bin/bash
#*********************************************************
#
# This build expect the following environme variables
#   EMEDIC_MAGE_FS_BASE_S3_URL
#
#*********************************************************
MAGE_FILESYSTEM_S3_URL="s3://emedic360-build-artifacts/magento-filesystem/magento2.2.2-48f3935f-8b1e-4a6e-8f4f-7a4f0578f961.tar.gz"

if [ -z $MAGE_FILESYSTEM_S3_URL ]; then
	echo -e  "[ERROR] MAGE_FILESYSTEM_S3_URL env variable is mandatory"
	exit 1
fi


rm -rf mage_filesystem
mkdir mage_filesystem

aws s3 cp $MAGE_FILESYSTEM_S3_URL mage_filesystem/



#docker build -t emedic/magento-base:1.0.0 .
