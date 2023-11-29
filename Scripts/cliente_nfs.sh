#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

# Actualizamos los repos

apt update

# Actualizar paquetes 

#apt upgrade

# Incluimos las variables del archivo .env

source .env

# Instalación de paquetes necesarios en el cliente NFS:

apt install nfs-common -y

# Montaje de la carpeta estableciendo la ip del servidor NFS:

mount $IP_NFS:/var/www/html /var/www/html

# Para que la unidad se monte automaticamente, y con los >> me añade al final en el /etc/fstab

echo "$IP_NFS:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab


