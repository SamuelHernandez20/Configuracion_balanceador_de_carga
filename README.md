# Practica-01-11
En este Práctica había que implementar nuevamente un balanceador de carga, pero esta vez la arquitectura consta de las siguientes **máquinas virtuales**:

1. Balanceador.
2. Frontal Web 1.
3. Frontal Web 2.
4. Servidor NFS (Para la carpeta compartida del **/var/www/html**).
5. Servidor de Base de Datos MySQL.
   
La arquitectura de estas máquinas virtuales, se destinarán para los siguientes propositos:

1. Un **balanceador de carga**, implementado con un **Apache HTTP Server** configurado como **proxy inverso**.
2.  Una capa de **front-end**, formada por **dos servidores web** con **Apache HTTP Server**.
3.  La máquina virtual con el **NFS** destinado a la compartición del **/var/www/html** para que los frontales tengan acceso al mismo contenido.
4.  La capa destinada para la parte trasera (Backend).

 # Estructura de Directorios:

````
.
├── README.md
├── conf
│   ├── load-balancer.conf
│   └── 000-default.conf
├── exports
│   ├── exports
├── htaccess
│   ├── .htaccess
├── php
│   ├── index.php
└── scripts
    ├── .env
    ├── install_load_balancer.sh
    ├── install_lamp_frontend.sh
    ├── install_lamp_backend.sh
    ├── setup_letsencrypt_https.sh
    └── deployFrontend.sh
    └── deployBackend.sh
    └── servidor_nfs.sh
    └── cliente_nfs.sh

````

# 1. Configuración del Proxy inverso:

`Desde la el install_load_balancer.sh de la maquina balanceadora`


Incluiré las variables del **.env** variables que a continuación van a ser imprescindibles:

````
source .env
````

Se procede con la instalación del servidor de **Apache**:

````
apt install apache2 -y
````

Para poder configurarlo como **proxy inverso**, y que balancee, procedo con la **activación** de los módulos necesarios de Apache para configurarlo como **proxy inverso**

````
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
````

Seguidamente paso con la habilitación del algoritmo de balanceo de carga, el más común es el **Round Robin**:

````
a2enmod lbmethod_byrequests
````

Despues pasamos a copiar archivo el archivo de configuracion del balanceador hacia el **sites-available**

````
cp ../conf/load-balancer.conf /etc/apache2/sites-available
````
De manera automatizada haciendo referencia a las variables del **.env**, reemplazamos las variables de la plantilla con las **direcciones ip privada** de las
maquinas virtuales **frontales**:

````
sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
````
````
sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf
````

Mediante el comando **a2ensite** procedo a habilitar el sitio del **virtualhost** actual:

````
a2ensite load-balancer.conf 
````
Luego procedo a deshabilitar el por defecto **000-default.conf**:

````
a2dissite 000-default.conf 
````

Reiniciamos:

````
systemctl restart apache2
````
Tras ello procedí a tirar desde la máquina del balanceador el **setup_letsencrypt_https.sh**, para tener configurado el **SSL** y posteriormente la navegación por **HTTPS** se produzca correctamente desde los frontales, aparte de ciertas configuraciones adicionales.

# 2. Configuración del Servidor NFS:


Se procede con la instalación del nfsserver:

````
apt install nfs-kernel-server -y
````
Creamos el directorio que queremos compartir entre las máquinas frontales:

````
mkdir -p /var/www/html
````

Damos permisos especiales:

````
chown nobody:nogroup /var/www/html
````
Copiamos el archivo exports hacia la ruta correspondiente, el cual nos permitirá establecer los permisos para la carpeta compartida, para la subred privada de los frontales:

````
cp ../exports/exports /etc/exports
````
````
sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports
````

Reiniciamos el servicio nfs del servidor 
````
systemctl restart nfs-kernel-server
````
# 3. Configuración de los clientes NFS:

Desde las 2 máquinas frontales se deberá de realizar la ejecución de este script **cliente_nfs.sh**, para que se monte en ambas máquinas la **carpeta compartida** del **servidor NFS**.
Tras realizarlo podemos comprobar el montaje mediante el comando `df -h`. Pero antes de realizar este apartado sería conveniente tirar el script **install_lamp_frontend.sh** en ambos frontales, para que tengamos ya previaemnte la carpeta **/var/www/html** y el montaje no falle.

Instalación de paquetes necesarios en el cliente NFS:

````
apt install nfs-common -y
````

Montaje de la carpeta estableciendo la ip privada del servidor NFS:

````
mount $IP_NFS:/var/www/html /var/www/html
````
Para que la unidad se monte automaticamente, y con los >> me añade al final en el /etc/fstab

````
echo "$IP_NFS:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
````
# 3. Configuración del Backend:

Previo a la tirada del **deployFrontend.sh**, procederé a ejecutar los scripts que conciernen a la instalación del backend y el despliegue de la base de datos (**install_lamp_backend.sh** y 
**deployBackend.sh**).

Desde el `install_lamp_backend.sh`

Instalo el SGBD de MySQL:

````
apt install mysql-server -y
````

configuro MySQL  para que acepete conxiones desde la ip privada:

````
sed -i "s/127.0.0.1/$MYSQL_PRIVATE/" /etc/mysql/mysql.conf.d/mysqld.cnf
````

Reiniciamos servicio

````
systemctl restart mysql
````
Desde el `deployBackend.sh`

Procedo a crear la base de datos de la cual tendrán acceso los frontales, configurando la ip del cliente para la subred: `$IP_CLIENTE_MYSQL = 172.31.%`
````
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@'$IP_CLIENTE_MYSQL'"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@'$IP_CLIENTE_MYSQL'"
````
# 3. Despliegue del Wordpress:

Desde cualquiera de los servidores frontales, ya que comparten recursos del **/var/www/html**, se procede con la ejecución del script que nos despliega el Wordpress de forma automatizada, haciendo uso de la utilidad **wp-cli**:

Eliminar descargas previas:

````
rm -rf /tmp/wp-cli.phar 
````
Descargamos utilidad wp-cli:

````
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
````
Permisos de ejecución al archivo:

````
chmod +x /tmp/wp-cli.phar
````
Movemos la utlidad y de esta forma lo podemos usar sin poner la ruta completa:

````
mv /tmp/wp-cli.phar /usr/local/bin/wp
````
Eliminamos instalaciones previas del Wordpress:

````
rm -rf /var/www/html/*
````
Descargamos el código fuente de Wordpress en **/var/www/html**

````
wp core download --locale=es_ES --path=/var/www/html --allow-root
````

Procedo con la creación del archivo de configuración de la base de datos, donde se estará haciendo uso de las variables que se lanzaron previamente en el **Backend**, y haciendo estebleciendo su **dirección ip privada** como **host** de la **base de datos**:

````
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root
````
Una vez que tenemos la base de datos creada y el archivo de configuración preparado podemos realizar la instalación de WordPress, donde será importante establecer en el dominio el del balanceador que es el que va a estar distribuyendo la carga entre ambos frontales:

````
wp core install \
  --url=$dominio \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN\
  --admin_password=$WORDPRESS_PASS \
  --admin_email=$WORDPRESS_email \
  --path=/var/www/html \
  --allow-root
````
Actualizacion:

````
wp core update --path=/var/www/html --allow-root
````
Instalamos un tema:

````
wp theme install sydney --activate --path=/var/www/html --allow-root
````
Instalamos un algunos plugins:

````
wp plugin update --path=/var/www/html --all --allow-root
````
Instalamos el plugin bbpress:

````
wp plugin install bbpress --activate --path=/var/www/html --allow-root
````
````
wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root
````
Nombre de la entrada
````
wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root
````
Para que el **HTTPS** funcione de manera correcta, habrá que establecer la variable a **on**, definiendola justo debajo de **COLLATE**, aunque puede estar en cualquier sitio del archivo de configuración:

````
sed -i "/COLLATE/a \$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php
````
Para que la reescritura de URL se aplique correctamente copiaremos el **.htaccess**, y se procede a habilitar mediante el comando **a2enmod rewrite**.

````
cp ../htaccess/.htaccess /var/www/html/
````
Será importante incluir la ejecución de este comando en el frontal opuesto al que se haya tirado el despliegue del Wordpress, para que la **reescritura de URLS** se aplique de forma existosa y no se reciba el error **404**.

````
a2enmod rewrite
````
````
systemctl restart apache2
````
````
chown -R www-data:www-data /var/www/html
````









