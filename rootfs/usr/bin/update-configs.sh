#!/bin/sh

php_ini=/etc/php7/php.ini
cli_php_ini=/etc/php7/cli/php.ini
php_fpm_conf=/etc/php7/php-fpm.conf

# Set PHP timezone
sed -i "s|date.timezone\s*=.*|date.timezone = ${PHP_TIMEZONE}|i" ${php_ini}
sed -i "s|date.timezone\s*=.*|date.timezone = ${PHP_TIMEZONE}|i" ${cli_php_ini}

# Set PHP memory limit
sed -i "s|memory_limit\s*=.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" ${php_ini}
sed -i "s|memory_limit\s*=.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" ${cli_php_ini}

# Error reporting
sed -i "s|display_errors\s*=.*|display_errors = ${PHP_DISPLAY_ERRORS}|i" ${php_ini}
sed -i "s|display_startup_errors\s*=.*|display_startup_errors = ${PHP_DISPLAY_ERRORS}|i" ${php_ini}
sed -i "s|display_errors\s*=.*|display_errors = ${PHP_DISPLAY_ERRORS}|i" ${cli_php_ini}
sed -i "s|display_startup_errors\s*=.*|display_startup_errors = ${PHP_DISPLAY_ERRORS}|i" ${cli_php_ini}

# Other params
#sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" ${php_ini}
#sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" ${php_ini}
#sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" ${php_ini}
#sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" ${php_ini}

