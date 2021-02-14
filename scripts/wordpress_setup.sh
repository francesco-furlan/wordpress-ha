#!/bin/bash
sudo -i
yum update -y
yum install -y httpd
amazon-linux-extras install -y php7.2
yum install wget -y
cd /var/www/html
echo "OK" > health.html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress
rm -rf latest.tar.gz
chmod -R 755 wp-content
chown -R apache:apache wp-content
chkconfig httpd on
service httpd start
WP_CONFIG_FILEPATH=/var/www/html/wp-config.php

if [ ! -f $WP_CONFIG_FILEPATH ]; then
    echo "<?php" >$WP_CONFIG_FILEPATH
    echo "define( 'DB_NAME', '${DB_NAME}' );" >>$WP_CONFIG_FILEPATH
    echo "define( 'DB_USER', '${DB_USER}' );" >>$WP_CONFIG_FILEPATH
    echo "define( 'DB_PASSWORD', '${DB_PASSWORD}' );" >>$WP_CONFIG_FILEPATH
    echo "define( 'DB_HOST', '${DB_HOST}:${DB_PORT}' );" >>$WP_CONFIG_FILEPATH
    echo "define( 'DB_CHARSET', 'utf8' );" >>$WP_CONFIG_FILEPATH
    echo "define( 'DB_COLLATE', '' );" >>$WP_CONFIG_FILEPATH
    curl https://api.wordpress.org/secret-key/1.1/salt/ >>$WP_CONFIG_FILEPATH
    echo "\$table_prefix = 'wp_';" >>$WP_CONFIG_FILEPATH
    echo "define( 'WP_DEBUG', false );" >>$WP_CONFIG_FILEPATH
    echo "if ( ! defined( 'ABSPATH' ) ) {" >>$WP_CONFIG_FILEPATH
    echo "	define( 'ABSPATH', __DIR__ . '/' );" >>$WP_CONFIG_FILEPATH
    echo "}" >>$WP_CONFIG_FILEPATH
    echo "require_once ABSPATH . 'wp-settings.php';" >>$WP_CONFIG_FILEPATH
fi
