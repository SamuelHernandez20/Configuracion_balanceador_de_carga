#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

# Actualizamos los repos

apt update

# Actualizar paquetes 

# instalar sgbd mysql

apt install mysql-server -y

#.env

source .env

# configuramos mysql  para que acepete conxiones desde la ip privada 

sed -i "s/127.0.0.1/$MYSQL_PRIVATE/" /etc/mysql/mysql.conf.d/mysqld.cnf


# reiniciamos servicio

systemctl restart mysql


