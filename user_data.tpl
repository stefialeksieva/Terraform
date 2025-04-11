#!/bin/bash
# Update and install necessary packages
yum update -y

# Remove any old PHP versions
yum remove -y php*

# Enable PHP 7.4 and install necessary packages
amazon-linux-extras enable php7.4
yum install -y httpd php php-mysqlnd php-fpm mariadb-client wget

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Check and ensure PHP 7.4 is installed correctly
php -v  # This should now show PHP 7.4.x

# Create the WordPress directory and set permissions
mkdir -p /var/www/html
cd /var/www/html

# Download WordPress
wp core download --locale=en_US

# Create the correct user and group if they don't exist
groupadd -f apache
useradd -g apache apache

# Set correct ownership and permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Set correct file permissions for files
find /var/www/html -type f -exec chmod 644 {} \;

# Generate wp-config.php file (ensure you replace these variables with actual values)
cat <<EOF > /var/www/html/wp-config.php
<?php
define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define('WP_HOME', 'https://wordpress.stefankaa.com');
define('WP_SITEURL', 'https://wordpress.stefankaa.com');
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
?>
EOF

# Create wp-config.php using WP-CLI
wp config create --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_password} --dbhost=${db_host} --skip-check


cat <<EOF > /var/www/html/.htaccess
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %%{HTTPS} off
RewriteRule ^(.*)$ https://%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301]
</IfModule>
EOF

# Install WordPress
wp core install --url="https://wordpress.stefankaa.com" --title="My WordPress Site" --admin_user=${admin_user} --admin_password=${admin_password} --admin_email=${admin_email}

# Install and activate plugins and themes
wp plugin install akismet --activate
wp theme install twentytwentyone --activate
wp plugin update --all

wp search-replace 'http://wordpress.stefankaa.com' 'https://wordpress.stefankaa.com' --all-tables
wp cache flush

sudo chown apache:apache /var/www/html/wp-config.php

# Navigate to the WordPress directory
cd /var/www/html

# Install the Really Simple SSL plugin
wp plugin install really-simple-ssl --activate

wp search-replace 'http://' 'https://' --skip-columns=guid

# Enable the event MPM instead of prefork
sed -i 's/^LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf

# Start PHP-FPM
systemctl start php-fpm
systemctl enable php-fpm

# Start Apache
systemctl start httpd
systemctl enable httpd

# Restart Apache to ensure the settings take effect
systemctl restart httpd

# Verify PHP version
php -v  # This should print the correct PHP 7.4 version

