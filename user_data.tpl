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
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}

define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define('WP_HOME', 'https://wordpress.stefankaa.com');
define('WP_SITEURL', 'https://wordpress.stefankaa.com');

\$table_prefix = 'wp_';

define( 'WP_DEBUG', true );
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
?>
EOF


cat <<EOF > /var/www/html/.htaccess
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %%{SERVER_PORT} !^443$
    RewriteRule (.*) https://%%{HTTP_HOST}%%{REQUEST_URI} [R=301,L]
    RewriteBase /
    RewriteRule ^index\.php$ - [L]
    RewriteCond %%{REQUEST_FILENAME} !-f
    RewriteCond %%{REQUEST_FILENAME} !-d
</IfModule>
php_value upload_max_filesize 3000M
php_value post_max_size 3000M
php_value memory_limit 3000M
EOF

# Install WordPress
wp core install --url="https://wordpress.stefankaa.com" --title="My WordPress Site" --admin_user=${admin_user} --admin_password=${admin_password} --admin_email=${admin_email}

# Install and activate plugins and themes
wp plugin install akismet --activate
wp theme install twentytwentyone --activate
wp plugin update --all

wp search-replace 'http://wordpress.stefankaa.com' 'https://wordpress.stefankaa.com' --all-tables --skip-columns=guid
wp cache flush

sudo chown apache:apache /var/www/html/wp-config.php


#wp search-replace 'http://' 'https://' --skip-columns=guid

# Add auto-login PHP script
cat << 'EOF' > /var/www/html/wp-auto-login.php
<?php
require_once( dirname(__FILE__) . '/wp-load.php' );

$token = isset($_GET['token']) ? sanitize_text_field($_GET['token']) : '';

if ($token !== '${auto_login_token}') {
    wp_die('Unauthorized access.');
}

$user = get_user_by('login', '${admin_user}');
if ($user) {
    wp_set_current_user($user->ID);
    wp_set_auth_cookie($user->ID);
    do_action('wp_login', $user->user_login, $user);
    wp_redirect(admin_url());
    exit;
} else {
    wp_die('Invalid user.');
}
EOF

# Secure the file
chown apache:apache /var/www/html/wp-auto-login.php
chmod 640 /var/www/html/wp-auto-login.php

# Enable the event MPM instead of prefork
sed -i 's/^LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf

sudo sed -i 's/^\s*memory_limit\s*=.*/memory_limit = 512M/' /etc/php.ini
sudo sed -i '/^\s*;*\s*realpath_cache_size\s*=.*/{s/^;\?//;s/=.*/= 4096k/}' /etc/php.ini
sudo sed -i '/^\s*;*\s*realpath_cache_ttl\s*=.*/{s/^;\?//;s/=.*/= 120/}' /etc/php.ini


#find /var/www/html/ -type f -exec sed -i 's|http://|https://|g' {} +

# Start PHP-FPM
systemctl start php-fpm
systemctl enable php-fpm

# Start Apache
systemctl start httpd
systemctl enable httpd

# Restart Apache to apply the changes
systemctl restart httpd
