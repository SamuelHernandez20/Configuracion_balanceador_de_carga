#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -ex

# Actualizamos los repos

apt update

# Actualizar paquetes 

#apt upgrade

#variables

source .env

#Instalar apache

apt install apache2 -y

# Activación de los módulos necesarios de Apache para configurarlo como proxy inverso

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer

#Habilitamos el balanceo de carga round robin

a2enmod lbmethod_byrequests

# Copiar archivo de configuracion 

cp ../conf/load-balancer.conf /etc/apache2/sites-available

#Reemplazamos las variables de la plantilla con las direcciones de los frontales

sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf


# habilitar vhost actual
a2ensite load-balancer.conf 

# deshabilitar el por defecto

a2dissite 000-default.conf 


#Reiniciamos

systemctl restart apache2



