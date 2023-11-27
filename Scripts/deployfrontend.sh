#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

# Actualizamos los repos

apt update

# Incluir variables

source .env

# Eliminar descargas previas:

rm -rf /tmp/wp-cli.phar 

# Descargamos utilidad wp-cli:

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

#Permisos de ejecución al archivo:

chmod +x /tmp/wp-cli.phar

# Movemos la utlidad y de esta forma lo podemos usar sin poner la ruta completa:

mv /tmp/wp-cli.phar /usr/local/bin/wp

#Eliminamos instalaciones previas del Wordpress

rm -rf /var/www/html/*

# Descargamos cod fuente Wordpress en /var/www/html

wp core download --locale=es_ES --path=/var/www/html --allow-root

mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"


# Creamos el archivo de configruacion 

wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root

# Una vez que tenemos la base de datos creada y el archivo de configuración preparado podemos realizar la instalación de WordPress 

wp core install \
  --url=$dominio \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN\
  --admin_password=$WORDPRESS_PASS \
  --admin_email=$WORDPRESS_email \
  --path=/var/www/html \
  --allow-root

# Actualizacion

wp core update --path=/var/www/html --allow-root

# Instalamos un tema:

wp theme install sydney --activate --path=/var/www/html --allow-root

# Instalamos un algunos plugins:

wp plugin update --path=/var/www/html --all --allow-root

# Instalamos el plugin bbpress:

wp plugin install bbpress --activate --path=/var/www/html --allow-root


wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root
# Nombre de la entrada

wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root

# reescritura

a2enmod rewrite

cp /home/ubuntu/practica01-09/htaccess/.htaccess /var/www/html/

chown -R www-data:www-data /var/www/html