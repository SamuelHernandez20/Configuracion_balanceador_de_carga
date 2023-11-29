#!/bin/bash

# Muestra todos los comandos que se han ejeutado.

set -ex

# Actualización de repositorios
 sudo apt update

# Actualización de paquetes

# sudo apt upgrade  

# Incluimos las variables del archivo .env

source .env

# Instalamos nfsserver:

apt install nfs-kernel-server -y

# Creamos el directorio que queremos compartir:

mkdir -p /var/www/html

# Damos permisos especiales:

chown nobody:nogroup /var/www/html

# Copiamos el archivo exports hacia la ruta correspondiente:

cp ../exports/exports /etc/exports

sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports

# Reiniciamos el servicio nfs del servidor 

systemctl restart nfs-kernel-server

