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




