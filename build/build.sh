#!/bin/bash
#*********************************************************
#
# This build expect the following environme variables
#   EMEDIC_MAGE_FS_BASE_S3_URL
#
#*********************************************************
#MAGE_FILESYSTEM_S3_URL="s3://emedic360-build-artifacts/magento-filesystem/magento2.2.2-48f3935f-8b1e-4a6e-8f4f-7a4f0578f961.tar.gz"

echo $MAGE_FILESYSTEM_S3_URL

if [ -z $MAGE_FILESYSTEM_S3_URL ]; then
	echo -e  "[ERROR] MAGE_FILESYSTEM_S3_URL env variable is mandatory"
	exit 1
fi


if [ -z $DOCKER_HUB_USER ]; then
	echo -e  "[ERROR] DOCKER_HUB_USER env variable is mandatory"
	exit 1
fi

if [ -z $DOCKER_HUB_PWD ]; then
	echo -e  "[ERROR] DOCKER_HUB_PWD env variable is mandatory"
	exit 1
fi

# Delete temporal folder
rm -rf mage_filesystem
mkdir mage_filesystem

# Copy filesystem tar file to a local directory
aws s3 cp $MAGE_FILESYSTEM_S3_URL mage_filesystem/filesystem.tar.gz

# Perform the build
IMAGE_TAG=`echo $CODEBUILD_BUILD_ID | cut -d':' -f2`
docker build -t emedic/magento-base:$IMAGE_TAG .


echo "Info: upload image to Docker Hub.."
docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PWD || { echo "Error en docker login"; exit 1; }
docker push emedic/magento-base:$IMAGE_TAG || { echo "Error en docker push"; exit 1; }
