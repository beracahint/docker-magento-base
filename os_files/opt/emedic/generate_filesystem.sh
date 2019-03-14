#!/bin/sh
# Generar filesystem cuando haya un cambio fuera de el codigo que tenemos en el repo docker-emedic-web

FILE_NAME=magento-`date +"%Y-%m-%d_%H-%M"`.tar
cd /var/www/html
tar --exclude "./var/cache" --exclude "./var/page_cache" --exclude "./pub/static" --exclude "./pub/var/cache" --exclude "./pub/var/composer_home" --exclude "./pub/var/generation" --exclude "./pub/var/page_cache" --exclude "./pub/var/view_preprocessed" --exclude './pub/media/catalog/product' -cf ../$FILE_NAME .
tar -rf ../$FILE_NAME pub/static/.htaccess
gzip ../$FILE_NAME
aws s3 cp ../${FILE_NAME}.gz s3://beracah-cicd/${FILE_NAME}.gz
rm ../${FILE_NAME}.gz
